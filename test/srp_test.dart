import 'package:srp/client.dart';
import 'package:srp/common.dart' as common;
import 'package:srp/config.dart';
import 'package:srp/salt.dart';
import 'package:srp/server.dart';
import 'package:test/test.dart';

import 'test_params.dart' as test_params;

void main() {
  test('srp test', () {
    final username = 'x@vipycm.com';
    final password = 'password';

    final config = Config(
      N: test_params.N,
      g: test_params.g,
      H: test_params.H,
    );
    final salt = common.generateSalt();

    final client = Client(config);
    final clientEphemeral = client.generateEphemeral();
    final privateKey = client.derivePrivateKey(
      username,
      password,
      salt,
    );

    final verifier = client.deriveVerifier(privateKey);

    final server = Server(config);
    final serverEphemeral = server.generateEphemeral(verifier);

    final clientSession = client.deriveSession(
      clientEphemeral.secret,
      serverEphemeral.public,
      salt,
      username,
      privateKey,
    );

    final serverSession = server.deriveSession(
      serverEphemeral.secret,
      clientEphemeral.public,
      salt,
      username,
      verifier,
      clientSession.proof,
    );

    client.verifySession(
      clientEphemeral.public,
      clientSession,
      serverSession.proof,
    );

    expect(clientSession.key.value, serverSession.key.value);
  });

  test('calculates correct private key (x)', () {
    const knownSalt =
        "89745850634486713533325212087918793186120190997980322339838986523015723769567";
    const username = "user123";
    const password = "I.am\$ecur3";
    const expectedPrivateKey =
        "29772980514109245574840505084565557138947153001435435553136250503013667858018";

    final salt = Salt(BigInt.parse(knownSalt));

    final config = Config(
      N: test_params.N,
      g: test_params.g,
      H: test_params.H,
    );
    final client = Client(config);
    final private = client.derivePrivateKey(username, password, salt);

    expect(private.value.toRadixString(10), equals(expectedPrivateKey));
  });
}
