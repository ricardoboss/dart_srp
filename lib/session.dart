import 'package:srp/session_key.dart';
import 'package:srp/session_proof.dart';

class Session {
  final SessionKey key;
  final SessionProof proof;

  Session({required this.key, required this.proof});
}
