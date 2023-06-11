import 'package:convert/convert.dart';

extension SrpInt on BigInt {
  String toHex() {
    final str = this.toRadixString(16);

    if (str.length.isEven) return str;

    return '0' + str;
  }

  List<int> toHexBytes() => hex.decoder.convert(this.toHex());
}
