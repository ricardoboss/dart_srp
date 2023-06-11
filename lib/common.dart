import 'dart:math';

import 'package:convert/convert.dart';
import 'package:srp/salt.dart';

const hashOutputBytes = 256 ~/ 8;

BigInt generateSecureRandom() {
  final random = Random.secure();
  final hexStr = hex
      .encode(List<int>.generate(hashOutputBytes, (i) => random.nextInt(256)));
  return BigInt.parse(hexStr, radix: 16);
}

Salt generateSalt() => Salt(generateSecureRandom());
