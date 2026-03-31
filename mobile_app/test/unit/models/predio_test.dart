import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/predios/domain/models/predio.dart';

void main() {
  group('Predio', () {
    final predioCompleto = Predio(
      predioId: 'pred_001',
      productorId: 'uid_123',
      nombrePredio: 'Finca El Porvenir',
      departamento: 'Santander',
      municipio: 'Lebrija',
      vereda: 'La Aguada',
      numeroRegistroICA: 'ICA-45892',
      areaRegistradaHa: 12.0,
      estadoPredio: 'ACTIVO',
    );

    final predioSinOpcionales = Predio(
      predioId: 'pred_002',
      productorId: 'uid_123',
      nombrePredio: 'Finca La Esperanza',
      departamento: 'Santander',
      municipio: 'Lebrija',
      estadoPredio: 'ACTIVO',
    );

    test('toMap incluye todos los campos obligatorios', () {
      final map = predioCompleto.toMap();

      expect(map['predioId'], 'pred_001');
      expect(map['productorId'], 'uid_123');
      expect(map['nombrePredio'], 'Finca El Porvenir');
      expect(map['departamento'], 'Santander');
      expect(map['municipio'], 'Lebrija');
      expect(map['estadoPredio'], 'ACTIVO');
    });

    test('toMap incluye campos opcionales cuando existen', () {
      final map = predioCompleto.toMap();

      expect(map['vereda'], 'La Aguada');
      expect(map['numeroRegistroICA'], 'ICA-45892');
      expect(map['areaRegistradaHa'], 12.0);
    });

    test('toMap campos opcionales son null cuando no se proveen', () {
      final map = predioSinOpcionales.toMap();

      expect(map['vereda'], isNull);
      expect(map['numeroRegistroICA'], isNull);
      expect(map['areaRegistradaHa'], isNull);
    });

    test('fromMap reconstruye el predio correctamente', () {
      final map = {
        'predioId': 'pred_001',
        'productorId': 'uid_123',
        'nombrePredio': 'Finca El Porvenir',
        'departamento': 'Santander',
        'municipio': 'Lebrija',
        'vereda': 'La Aguada',
        'numeroRegistroICA': 'ICA-45892',
        'areaRegistradaHa': 12.0,
        'estadoPredio': 'ACTIVO',
        'createdAt': null,
        'updatedAt': null,
      };

      final predio = Predio.fromMap(map);

      expect(predio.predioId, 'pred_001');
      expect(predio.productorId, 'uid_123');
      expect(predio.nombrePredio, 'Finca El Porvenir');
      expect(predio.departamento, 'Santander');
      expect(predio.municipio, 'Lebrija');
      expect(predio.vereda, 'La Aguada');
      expect(predio.numeroRegistroICA, 'ICA-45892');
      expect(predio.areaRegistradaHa, 12.0);
      expect(predio.estadoPredio, 'ACTIVO');
    });

    test('fromMap usa ACTIVO como estadoPredio por defecto', () {
      final map = {
        'predioId': 'pred_003',
        'productorId': 'uid_123',
        'nombrePredio': 'Finca Nueva',
        'departamento': 'Santander',
        'municipio': 'Lebrija',
      };

      final predio = Predio.fromMap(map);
      expect(predio.estadoPredio, 'ACTIVO');
    });

    test('fromMap maneja areaRegistradaHa como entero correctamente', () {
      final map = {
        'predioId': 'pred_004',
        'productorId': 'uid_123',
        'nombrePredio': 'Finca Prueba',
        'departamento': 'Santander',
        'municipio': 'Lebrija',
        'areaRegistradaHa': 8,
        'estadoPredio': 'ACTIVO',
      };

      final predio = Predio.fromMap(map);
      expect(predio.areaRegistradaHa, 8.0);
      expect(predio.areaRegistradaHa, isA<double>());
    });

    test('fromMap campos opcionales son null cuando no vienen en el map', () {
      final map = {
        'predioId': 'pred_005',
        'productorId': 'uid_123',
        'nombrePredio': 'Finca Mínima',
        'departamento': 'Santander',
        'municipio': 'Lebrija',
        'estadoPredio': 'ACTIVO',
      };

      final predio = Predio.fromMap(map);
      expect(predio.vereda, isNull);
      expect(predio.numeroRegistroICA, isNull);
      expect(predio.areaRegistradaHa, isNull);
    });
  });
}