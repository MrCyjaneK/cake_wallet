import 'package:cake_wallet/core/wallet_creation_service.dart';
import 'package:cake_wallet/ethereum/ethereum.dart';
import 'package:cake_wallet/polygon/polygon.dart';
import 'package:cake_wallet/store/app_store.dart';
import 'package:cake_wallet/view_model/hardware_wallet/ledger_view_model.dart';
import 'package:cake_wallet/view_model/wallet_creation_vm.dart';
import 'package:cw_core/wallet_base.dart';
import 'package:cw_core/wallet_credentials.dart';
import 'package:cw_core/wallet_info.dart';
import 'package:cw_core/wallet_type.dart';
import 'package:cw_evm/evm_chain_wallet_creation_credentials.dart';
import 'package:hive/hive.dart';
import 'package:mobx/mobx.dart';

part 'wallet_hardware_restore_view_model.g.dart';

class WalletHardwareRestoreViewModel = WalletHardwareRestoreViewModelBase
    with _$WalletHardwareRestoreViewModel;

abstract class WalletHardwareRestoreViewModelBase extends WalletCreationVM with Store {
  final LedgerViewModel ledgerViewModel;

  int _nextIndex = 0;

  WalletHardwareRestoreViewModelBase(this.ledgerViewModel, AppStore appStore,
      WalletCreationService walletCreationService, Box<WalletInfo> walletInfoSource,
      {required WalletType type})
      : super(appStore, walletInfoSource, walletCreationService, type: type, isRecovery: true);

  @observable
  String name = "";

  @observable
  String? selectedAccount = null;

  @observable
  bool isLoadingMoreAccounts = false;

  // @observable
  ObservableList<String> availableAccounts = ObservableList();

  @action
  Future<void> getNextAvailableAccounts(int limit) async {
    List<String> accounts;
    switch (type) {
      case WalletType.ethereum:
        accounts =
            await ethereum!.getHardwareWalletAccounts(ledgerViewModel, index: _nextIndex, limit: limit);
        break;
      case WalletType.polygon:
        accounts =
            await polygon!.getHardwareWalletAccounts(ledgerViewModel, index: _nextIndex, limit: limit);
        break;
      default:
        return;
    }

    availableAccounts.addAll(accounts);
    isLoadingMoreAccounts = false;
    _nextIndex += limit;
  }

  @override
  WalletCredentials getCredentials(dynamic _options) {
    final address = selectedAccount!;
    WalletCredentials credentials;
    switch (type) {
      case WalletType.ethereum:
        credentials =
            ethereum!.createEthereumHardwareWalletCredentials(name: name, address: address);
        break;
      case WalletType.polygon:
        credentials =
            polygon!.createPolygonHardwareWalletCredentials(name: name, address: address);
        break;
      default:
        throw Exception('Unexpected type: ${type.toString()}');
    }

    credentials.hardwareWalletType = HardwareWalletType.ledger;

    return credentials;
  }

  @override
  Future<WalletBase> process(WalletCredentials credentials) async {
    walletCreationService.changeWalletType(type: type);
    final cred = credentials as EVMChainRestoreWalletFromHardware;
    credentials.walletInfo?.address = cred.address;
    return walletCreationService.restoreFromHardwareWallet(credentials);
  }
}