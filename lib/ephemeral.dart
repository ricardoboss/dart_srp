import 'package:srp/public_ephemeral.dart';
import 'package:srp/secret_ephemeral.dart';

class Ephemeral {
  final PublicEphemeral public;
  final SecretEphemeral secret;

  Ephemeral({required this.public, required this.secret});
}
