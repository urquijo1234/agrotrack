import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository({AuthService? authService})
      : _authService = authService ?? AuthService();

  Future<UserCredential> register({
    required String email,
    required String password,
  }) async {
    return await _authService.registerWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}