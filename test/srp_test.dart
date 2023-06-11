import 'package:srp/srp_client.dart';
import 'test_params.dart' as test_params;
import 'package:srp/common.dart' as common;
import 'package:srp/srp_config.dart';
import 'package:srp/srp_server.dart';
import 'package:test/test.dart';

void main() {
  test('srp test', () {
    final username = 'x@vipycm.com';
    final password = 'password';

    final config = SrpConfig(
      N: test_params.N,
      g: test_params.g,
      H: test_params.H,
    );
    final salt = common.generateSalt();

    final client = SrpClient(config);
    final clientEphemeral = client.generateEphemeral();
    final privateKey = client.derivePrivateKey(
      username,
      password,
      salt,
    );

    final verifier = client.deriveVerifier(privateKey);

    final server = SrpServer(config);
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
}
