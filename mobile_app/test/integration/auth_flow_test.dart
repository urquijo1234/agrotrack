import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile_app/features/auth/data/repositories/auth_repository.dart';
import 'package:mobile_app/features/auth/data/services/auth_service.dart';
import 'package:mobile_app/features/auth/data/services/productor_service.dart';
import 'package:mobile_app/features/auth/domain/models/productor.dart';
import 'package:firebase_auth/firebase_auth.dart';

@GenerateMocks([AuthService, ProductorService, UserCredential, User])
import 'auth_flow_test.mocks.dart';

void main() {
  late AuthRepository repository;
  late MockAuthService mockAuthService;
  late MockProductorService mockProductorService;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;

  setUp(() {
    mockAuthService = MockAuthService();
    mockProductorService = MockProductorService();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();

    when(mockUserCredential.user).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('uid_test_123');

    repository = AuthRepository(
      authService: mockAuthService,
      productorService: mockProductorService,
    );
  });

  // ==========================================
  // FLUJO DE REGISTRO
  // ==========================================
  group('Flujo de registro', () {
    test('registro exitoso crea usuario y productor', () async {
      // Arrange
      when(mockAuthService.registerWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockUserCredential);

      when(mockProductorService.createProductor(any))
          .thenAnswer((_) async => {});

      // Act
      final result = await repository.register(
        nombreCompleto: 'Luis Alberto Gómez',
        email: 'luis@correo.com',
        password: 'password123',
        telefono: '+57 3100000000',
      );

      // Assert
      expect(result, isNotNull);
      verify(mockAuthService.registerWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).called(1);
      verify(mockProductorService.createProductor(any)).called(1);
    });

    test('registro sin telefono funciona correctamente', () async {
      // Arrange
      when(mockAuthService.registerWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockUserCredential);

      when(mockProductorService.createProductor(any))
          .thenAnswer((_) async => {});

      // Act
      final result = await repository.register(
        nombreCompleto: 'Ana Pérez',
        email: 'ana@correo.com',
        password: 'password123',
      );

      // Assert
      expect(result, isNotNull);
    });

    test('registro falla si Firebase lanza excepcion', () async {
      // Arrange
      when(mockAuthService.registerWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

      // Act & Assert
      expect(
        () => repository.register(
          nombreCompleto: 'Luis Gómez',
          email: 'luis@correo.com',
          password: 'password123',
        ),
        throwsA(isA<FirebaseAuthException>()),
      );
    });
  });

  // ==========================================
  // FLUJO DE LOGIN
  // ==========================================
  group('Flujo de login', () {
    test('login exitoso retorna UserCredential', () async {
      // Arrange
      when(mockAuthService.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockUserCredential);

      // Act
      final result = await repository.login(
        email: 'luis@correo.com',
        password: 'password123',
      );

      // Assert
      expect(result, isNotNull);
      verify(mockAuthService.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).called(1);
    });

    test('login falla con credenciales incorrectas', () async {
      // Arrange
      when(mockAuthService.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(FirebaseAuthException(code: 'invalid-credential'));

      // Act & Assert
      expect(
        () => repository.login(
          email: 'luis@correo.com',
          password: 'wrongpassword',
        ),
        throwsA(isA<FirebaseAuthException>()),
      );
    });
  });

  // ==========================================
  // FLUJO DE LOGOUT
  // ==========================================
  group('Flujo de logout', () {
    test('logout llama signOut correctamente', () async {
      // Arrange
      when(mockAuthService.signOut()).thenAnswer((_) async => {});

      // Act
      await repository.logout();

      // Assert
      verify(mockAuthService.signOut()).called(1);
    });
  });
}