import 'dart:typed_data';

import 'package:convert/convert.dart';

extension SrpInt on BigInt {
  String toHex() {
    final str = this.toRadixString(16).toUpperCase();

    if (str.length.isEven) return str;

    return '0' + str;
  }

  Uint8List toBytes() => Uint8List.fromList(hex.decoder.convert(this.toHex()).reversed.toList());

  static BigInt fromBytes(List<int> data) {
    final reversed = data.reversed.toList(growable: false);
    final hexData = hex.encode(reversed);

    return BigInt.parse(hexData, radix: 16);
  }
}
