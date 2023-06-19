import 'dart:math';

import 'package:convert/convert.dart';
import 'package:srp/big_int_extensions.dart';
import 'package:srp/config.dart';
import 'package:srp/salt.dart';

const hashOutputBytes = 256 ~/ 8;

BigInt generateSecureRandom() {
  final random = Random.secure();
  final hexStr = hex
      .encode(List<int>.generate(hashOutputBytes, (i) => random.nextInt(256)));
  return BigInt.parse(hexStr, radix: 16);
}

Salt generateSalt() => Salt(generateSecureRandom());

BigInt calculateWowSessionKey(Config config, BigInt S) {
  final H = config.H;

  final sBytes = S.toHexBytes().reversed.toList().asMap().entries;

  final evenPairs = sBytes.toList()..retainWhere((pair) => pair.key % 2 == 0);
  final evenBytes = evenPairs.map((pair) => pair.value);

  final oddPairs = sBytes.toList()..retainWhere((pair) => pair.key % 2 == 1);
  final oddBytes = oddPairs.map((pair) => pair.value);

  final evenHashBytes =
      H(evenBytes).toHexBytes().reversed.take(20).toList(growable: false);
  final oddHashBytes =
      H(oddBytes).toHexBytes().reversed.take(20).toList(growable: false);

  final interleaved = <int>[];
  for (var i = 0; i < 40; i++) {
    interleaved.add(i % 2 == 0 ? evenHashBytes[i ~/ 2] : oddHashBytes[i ~/ 2]);
  }

  // FIXME: this part doesn't work yet
  final interleavedHex = hex.encode(interleaved);
  return BigInt.parse(interleavedHex, radix: 16);
}
