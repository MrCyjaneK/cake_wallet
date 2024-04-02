import 'package:cake_wallet/ionia/ionia_virtual_card.dart';

abstract class CakePayCreateAccountState {}

class CakePayAccountCreateStateInitial extends CakePayCreateAccountState {}

class CakePayAccountCreateStateSuccess extends CakePayCreateAccountState {}

class CakePayAccountCreateStateLoading extends CakePayCreateAccountState {}

class CakePayAccountCreateStateFailure extends CakePayCreateAccountState {
  CakePayAccountCreateStateFailure({required this.error});

  final String error;
}

abstract class CakePayOtpState {}

class CakePayOtpValidating extends CakePayOtpState {}

class CakePayOtpSuccess extends CakePayOtpState {}

class CakePayOtpSendDisabled extends CakePayOtpState {}

class CakePayOtpSendEnabled extends CakePayOtpState {}

class CakePayOtpFailure extends CakePayOtpState {
  CakePayOtpFailure({required this.error});

  final String error;
}

class CakePayCreateCardState {}

class CakePayCreateCardStateSuccess extends CakePayCreateCardState {}

class CakePayCreateCardStateLoading extends CakePayCreateCardState {}

class CakePayCreateCardStateFailure extends CakePayCreateCardState {
  CakePayCreateCardStateFailure({required this.error});

  final String error;
}

class CakePayCardsState {}

class CakePayCardsStateNoCards extends CakePayCardsState {}

class CakePayCardsStateFetching extends CakePayCardsState {}

class CakePayCardsStateFailure extends CakePayCardsState {}

class CakePayCardsStateSuccess extends CakePayCardsState {
  CakePayCardsStateSuccess({required this.card});

  final CakePayVirtualCard card;
}

abstract class CakePayVendorState {}

class InitialCakePayVendorLoadingState extends CakePayVendorState {}

class CakePayVendorLoadingState extends CakePayVendorState {}

class CakePayVendorLoadedState extends CakePayVendorState {}
