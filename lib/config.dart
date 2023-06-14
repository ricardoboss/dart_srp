import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:srp/big_int_extensions.dart';
import 'package:srp/srp_exception.dart';

typedef HashAlgorithm = BigInt Function(Iterable args);

class Config {
  /// A thin wrapper around [H] to hash multiple values (accepts [BigInt] or
  /// [String]).
  static BigInt applyH(Hash H, Iterable args) {
    final output = new AccumulatorSink<Digest>();
    final input = H.startChunkedConversion(output);
    for (final arg in args) {
      if (arg is BigInt) {
        input.add(arg.toHexBytes());
      } else if (arg is String) {
        input.add(utf8.encode(arg));
      } else {
        throw new SrpException(
            "Invalid variable type passed (only BigInt and String allowed)");
      }
    }
    input.close();

    final hexStr = output.events.single.toString();
    output.close();

    return BigInt.parse(hexStr, radix: 16);
  }

  /// A large, safe prime N for computing g^x mod N
  final BigInt N;

  /// The generator g of the multiplicative group
  final BigInt g;

  BigInt? _k;

  /// The derived key [k] = H(N, g) or the one given in the constructor.
  BigInt get k => _k ??= H([N, g]);

  /// The algorithm H
  final HashAlgorithm H;

  /// This class holds all the required information for deriving keys during the
  /// SRP procedure.
  /// If [k] is not specified, it will be derived using H(N, g) as required by
  /// SRP-6a. Pass 3 for SRP-6.
  Config({
    required this.N,
    required this.g,
    BigInt? k,
    Hash H = sha256,
  })  : H = ((args) => applyH(H, args)),
        _k = k;
}
