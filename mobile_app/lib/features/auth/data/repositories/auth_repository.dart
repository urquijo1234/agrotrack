import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/productor.dart';
import '../services/auth_service.dart';
import '../services/productor_service.dart';

class AuthRepository {
  final AuthService _authService;
  final ProductorService _productorService;

  AuthRepository({
    AuthService? authService,
    ProductorService? productorService,
  })  : _authService = authService ?? AuthService(),
        _productorService = productorService ?? ProductorService();

  Future<UserCredential> register({
    required String nombreCompleto,
    required String email,
    required String password,
    String? telefono,
  }) async {
    final userCredential = await _authService.registerWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-null',
        message: 'No fue posible obtener el usuario registrado.',
      );
    }

    final productor = Productor(
      productorId: user.uid,
      uidAuth: user.uid,
      nombreCompleto: nombreCompleto.trim(),
      correo: email.trim(),
      telefono: telefono != null && telefono.trim().isNotEmpty
          ? telefono.trim()
          : null,
      estadoCuenta: 'ACTIVO',
    );

    await _productorService.createProductor(productor);

    return userCredential;
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await _authService.signOut();
  }


 Future<void> resetPassword(String email) async {
    try {
     
      await _authService.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      // Opcional: Puedes mapear errores específicos aquí
      // ej: if (e.code == 'user-not-found') ...
      rethrow; 
    }
  }
}