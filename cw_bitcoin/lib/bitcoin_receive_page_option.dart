import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:cw_core/receive_page_option.dart';

class BitcoinReceivePageOption implements ReceivePageOption {
  static const p2wpkh = BitcoinReceivePageOption._('Segwit (P2WPKH)');
  static const p2tr = BitcoinReceivePageOption._('Taproot (P2TR)');
  static const p2wsh = BitcoinReceivePageOption._('Segwit (P2WSH)');
  static const p2pkh = BitcoinReceivePageOption._('Legacy (P2PKH)');

  const BitcoinReceivePageOption._(this.value);

  final String value;

  String toString() {
    return value;
  }

  static const all = [
    BitcoinReceivePageOption.p2wpkh,
    BitcoinReceivePageOption.p2tr,
    BitcoinReceivePageOption.p2wsh,
    BitcoinReceivePageOption.p2pkh
  ];

  factory BitcoinReceivePageOption.fromType(BitcoinAddressType type) {
    switch (type) {
      case BitcoinAddressType.p2tr:
        return BitcoinReceivePageOption.p2tr;
      case BitcoinAddressType.p2wsh:
        return BitcoinReceivePageOption.p2wsh;
      case BitcoinAddressType.p2pkh:
        return BitcoinReceivePageOption.p2pkh;
      case BitcoinAddressType.p2wpkh:
      default:
        return BitcoinReceivePageOption.p2wpkh;
    }
  }
}