import 'dart:async';

import 'package:cw_monero/api/wallet.dart';
import 'package:cw_monero/monero_account_list.dart';
import 'package:monero/monero.dart' as monero;

monero.wallet? wptr = null;
bool get isViewOnly => int.tryParse(monero.Wallet_secretSpendKey(wptr!)) == 0;

int _wlptrForW = 0;
monero.WalletListener? _wlptr = null;

monero.WalletListener? getWlptr() {
  if (wptr == null) return null;
  if (wptr!.address == _wlptrForW) return _wlptr!;
  _wlptrForW = wptr!.address;
  _wlptr = monero.MONERO_cw_getWalletListener(wptr!);
  return _wlptr!;
}

monero.SubaddressAccount? subaddressAccount;

bool isUpdating = false;

void refreshAccounts() {
  try {
    isUpdating = true;
    subaddressAccount = monero.Wallet_subaddressAccount(wptr!);
    monero.SubaddressAccount_refresh(subaddressAccount!);
    isUpdating = false;
  } catch (e) {
    isUpdating = false;
    rethrow;
  }
}

List<monero.SubaddressAccountRow> getAllAccount() {
  // final size = monero.Wallet_numSubaddressAccounts(wptr!);
  refreshAccounts();
  int size = monero.SubaddressAccount_getAll_size(subaddressAccount!);
  if (size == 0) {
    monero.Wallet_addSubaddressAccount(wptr!);
    monero.Wallet_status(wptr!);
    return [];
  }
  return List.generate(size, (index) {
    return monero.SubaddressAccount_getAll_byIndex(subaddressAccount!, index: index);
  });
}

void addAccountSync({required String label}) {
  monero.Wallet_addSubaddressAccount(wptr!, label: label);
}

void setLabelForAccountSync({required int accountIndex, required String label}) {
  monero.SubaddressAccount_setLabel(subaddressAccount!, accountIndex: accountIndex, label: label);
  MoneroAccountListBase.cachedAccounts[wptr!.address] = [];
  refreshAccounts();
}

void _addAccount(String label) => addAccountSync(label: label);

void _setLabelForAccount(Map<String, dynamic> args) {
  final label = args['label'] as String;
  final accountIndex = args['accountIndex'] as int;

  setLabelForAccountSync(label: label, accountIndex: accountIndex);
}

Future<void> addAccount({required String label}) async {
  _addAccount(label);
  unawaited(store());
}

Future<void> setLabelForAccount({required int accountIndex, required String label}) async {
    _setLabelForAccount({'accountIndex': accountIndex, 'label': label});
    unawaited(store());
}