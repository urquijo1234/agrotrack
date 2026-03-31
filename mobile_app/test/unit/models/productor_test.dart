import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/auth/domain/models/productor.dart';

void main() {
  group('Productor', () {
    final productorCompleto = Productor(
      productorId: 'uid_123',
      uidAuth: 'uid_123',
      nombreCompleto: 'Luis Alberto Gómez',
      correo: 'luis@correo.com',
      telefono: '+57 3100000000',
      estadoCuenta: 'ACTIVO',
    );

    final productorSinTelefono = Productor(
      productorId: 'uid_456',
      uidAuth: 'uid_456',
      nombreCompleto: 'Ana Pérez',
      correo: 'ana@correo.com',
      estadoCuenta: 'ACTIVO',
    );

    test('toMap incluye todos los campos obligatorios', () {
      final map = productorCompleto.toMap();

      expect(map['productorId'], 'uid_123');
      expect(map['uidAuth'], 'uid_123');
      expect(map['nombreCompleto'], 'Luis Alberto Gómez');
      expect(map['correo'], 'luis@correo.com');
      expect(map['estadoCuenta'], 'ACTIVO');
    });

    test('toMap incluye telefono cuando existe', () {
      final map = productorCompleto.toMap();
      expect(map['telefono'], '+57 3100000000');
    });

    test('toMap telefono es null cuando no se provee', () {
      final map = productorSinTelefono.toMap();
      expect(map['telefono'], isNull);
    });

    test('productorId coincide con uidAuth', () {
      expect(productorCompleto.productorId, productorCompleto.uidAuth);
    });

    test('estadoCuenta es ACTIVO por defecto', () {
      expect(productorCompleto.estadoCuenta, 'ACTIVO');
    });
  });
}