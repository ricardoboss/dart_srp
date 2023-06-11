import 'package:srp/value_object.dart';

class PrivateKey extends ValueObject<BigInt> {
  const PrivateKey(super.value);
}
