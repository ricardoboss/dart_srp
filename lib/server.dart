import 'package:srp/verifier.dart';
import 'package:srp/common.dart' as common;
import 'package:srp/ephemeral.dart';
import 'package:srp/public_ephemeral.dart';
import 'package:srp/salt.dart';
import 'package:srp/secret_ephemeral.dart';
import 'package:srp/session.dart';
import 'package:srp/session_key.dart';
import 'package:srp/session_proof.dart';
import 'package:srp/config.dart';
import 'package:srp/srp_exception.dart';

class Server {
  final Config config;

  const Server(this.config);

  Ephemeral generateEphemeral(Verifier verifier) {
    final N = config.N;
    final g = config.g;
    final k = config.k;

    final v = verifier.value;

    final b = common.generateSecureRandom();
    final B = (k * v + g.modPow(b, N)) % N;

    return Ephemeral(secret: SecretEphemeral(b), public: PublicEphemeral(B));
  }

  Session deriveSession(
    SecretEphemeral serverSecretEphemeral,
    PublicEphemeral clientPublicEphemeral,
    Salt salt,
    String username,
    Verifier verifier,
    SessionProof clientSessionProof,
  ) {
    final N = config.N;
    final g = config.g;
    final k = config.k;
    final H = config.H;

    final b = serverSecretEphemeral.value;
    final A = clientPublicEphemeral.value;
    final s = salt.value;
    final I = username;
    final v = verifier.value;

    if (A % N == 0) {
      throw SrpException('the client sent an invalid public ephemeral');
    }

    final B = (k * v + g.modPow(b, N)) % N;
    final u = H([A, B]);

    final S = (A * (v.modPow(u, N))).modPow(b, N);

    final K = common.calculateWowSessionKey(config, S);
    // final K = H([S]);

    final M = H([
      H([N]) ^ (H([g])),
      H([I]),
      s,
      A,
      B,
      K
    ]);

    final expected = M;
    final actual = clientSessionProof.value;

    if (actual != expected) {
      throw SrpException('Client provided session proof is invalid');
    }

    final P = H([A, M, K]);

    return Session(key: SessionKey(K), proof: SessionProof(P));
  }
}
