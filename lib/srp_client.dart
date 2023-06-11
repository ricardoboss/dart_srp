import 'package:srp/verifier.dart';
import 'package:srp/common.dart' as common;
import 'package:srp/ephemeral.dart';
import 'package:srp/private_key.dart';
import 'package:srp/public_ephemeral.dart';
import 'package:srp/salt.dart';
import 'package:srp/secret_ephemeral.dart';
import 'package:srp/session.dart';
import 'package:srp/session_key.dart';
import 'package:srp/session_proof.dart';
import 'package:srp/srp_config.dart';
import 'package:srp/srp_exception.dart';

class SrpClient {
  final SrpConfig config;

  const SrpClient(this.config);

  PrivateKey derivePrivateKey(
    String username,
    String password,
    Salt salt,
  ) {
    final H = config.H;
    final s = salt.value;
    final I = username;
    final p = password;

    final x = H([
      s,
      H(['$I:$p']),
    ]);

    return PrivateKey(x);
  }

  Verifier deriveVerifier(PrivateKey privateKey) {
    final x = privateKey.value;
    final g = config.g;
    final N = config.N;

    final v = g.modPow(x, N);

    return Verifier(v);
  }

  Ephemeral generateEphemeral() {
    final N = config.N;
    final g = config.g;

    final a = common.generateSecureRandom();
    final A = g.modPow(a, N);

    return Ephemeral(secret: SecretEphemeral(a), public: PublicEphemeral(A));
  }

  Session deriveSession(
    SecretEphemeral clientSecretEphemeral,
    PublicEphemeral serverPublicEphemeral,
    Salt salt,
    String username,
    PrivateKey privateKey,
  ) {
    final H = config.H;
    final N = config.N;
    final g = config.g;
    final k = config.k;

    final a = clientSecretEphemeral.value;
    final B = serverPublicEphemeral.value;
    final s = salt.value;
    final I = username;
    final x = privateKey.value;

    if (B % N == 0) {
      throw SrpException('The server sent an invalid public ephemeral');
    }

    final A = g.modPow(a, N);
    final u = H([A, B]);

    if (u == 0) {
      throw SrpException('The random scrambling parameter ended up being 0');
    }

    final S = (B - (k * (g.modPow(x, N)))).modPow(a + (u * x), N);

    final K = H([S]);

    final M = H([
      H([N]) ^ H([g]),
      H([I]),
      s,
      A,
      B,
      K,
    ]);

    return Session(key: SessionKey(K), proof: SessionProof(M));
  }

  void verifySession(
    PublicEphemeral clientPublicEphemeral,
    Session clientSession,
    SessionProof serverSessionProof,
  ) {
    final H = config.H;
    final A = clientPublicEphemeral.value;
    final M = clientSession.proof.value;
    final K = clientSession.key.value;

    final expectedProof = H([A, M, K]);
    final actualProof = serverSessionProof.value;

    if (actualProof != expectedProof) {
      throw SrpException('Server provided session proof is invalid');
    }
  }
}
