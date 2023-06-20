import 'package:srp/big_int_extensions.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  test('BigInteger from byte list conversions work as expected', () {
    final bytes = [0x12, 0x48];

    final bigInt = SrpInt.fromBytes(bytes);

    expect(bigInt, equals(BigInt.from(18450)));

    final roundtrip = bigInt.toBytes();

    expect(roundtrip, equals(bytes));
  });
}