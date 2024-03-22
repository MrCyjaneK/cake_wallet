import 'package:cake_wallet/generated/i18n.dart';
import 'package:cake_wallet/reactions/wallet_connect.dart';
import 'package:cake_wallet/routes.dart';
import 'package:cake_wallet/store/app_store.dart';
import 'package:cake_wallet/store/authentication_store.dart';
import 'package:cake_wallet/store/settings_store.dart';
import 'package:cake_wallet/utils/payment_request.dart';
import 'package:cw_core/node.dart';
import 'package:cw_core/wallet_type.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobx/mobx.dart';

part 'link_view_model.g.dart';

class LinkViewModel = LinkViewModelBase with _$LinkViewModel;

abstract class LinkViewModelBase with Store {
  LinkViewModelBase({
    required this.settingsStore,
    required this.appStore,
    required this.authenticationStore,
    required this.navigatorKey,
  }) {}

  bool torStarted = false;
  final SettingsStore settingsStore;
  final AppStore appStore;
  final AuthenticationStore authenticationStore;
  final GlobalKey<NavigatorState> navigatorKey;
  Uri? currentLink;

  bool get _isValidPaymentUri => currentLink?.path.isNotEmpty ?? false;
  bool get isWalletConnectLink => currentLink?.authority == 'wc';
  bool get isNanoGptLink => currentLink?.scheme == 'nano-gpt';

  String? getRouteToGo() {
    if (isWalletConnectLink) {
      if (!isEVMCompatibleChain(appStore.wallet!.type)) {
        _nonETHWalletErrorToast(S.current.switchToEVMCompatibleWallet);
        return null;
      }
      return Routes.walletConnectConnectionsListing;
    }

    if (authenticationStore.state == AuthenticationState.uninitialized) {
      return null;
    }

    if (isNanoGptLink) {
      switch (currentLink?.authority ?? '') {
        case "exchange":
          return Routes.exchange;
        case "send":
          return Routes.send;
        case "buy":
          return Routes.buySellPage;
      }
    }

    if (_isValidPaymentUri) {
      return Routes.send;
    }

    return null;
  }

  dynamic getRouteArgs() {
    if (isWalletConnectLink) {
      return currentLink;
    }

    if (isNanoGptLink) {
      switch (currentLink?.authority ?? '') {
        case "exchange":
        case "send":
          return PaymentRequest.fromUri(currentLink);
        case "buy":
          return true;
      }
    }

    if (_isValidPaymentUri) {
      return PaymentRequest.fromUri(currentLink);
    }

    return null;
  }

  Future<void> _nonETHWalletErrorToast(String message) async {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.SNACKBAR,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> handleLink() async {
    print("link view model handle link");
    String? route = getRouteToGo();
    dynamic args = getRouteArgs();
    if (route != null) {
      if (appStore.wallet == null) {
        return;
      }
      navigatorKey.currentState?.pushNamed(
        route,
        arguments: args,
      );
      currentLink = null;
    }
  }
}