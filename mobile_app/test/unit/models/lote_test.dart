import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/lotes/domain/models/lote.dart';

void main() {
  group('Lote', () {
    final loteCompleto = Lote(
      loteId: 'lot_001',
      predioId: 'pred_001',
      productorId: 'uid_123',
      nombreLote: 'Lote Norte',
      codigoLote: 'LN-01',
      areaHectareas: 6.5,
      especieVegetalActual: 'Piña',
      variedadActual: 'Perolera',
      estadoLote: 'ACTIVO',
      observaciones: 'Lote de mayor productividad',
    );

    final loteSinOpcionales = Lote(
      loteId: 'lot_002',
      predioId: 'pred_001',
      productorId: 'uid_123',
      nombreLote: 'Lote Sur',
      areaHectareas: 3.0,
      especieVegetalActual: 'Mango',
      estadoLote: 'ACTIVO',
    );

    test('toMap incluye todos los campos obligatorios', () {
      final map = loteCompleto.toMap();

      expect(map['loteId'], 'lot_001');
      expect(map['predioId'], 'pred_001');
      expect(map['productorId'], 'uid_123');
      expect(map['nombreLote'], 'Lote Norte');
      expect(map['areaHectareas'], 6.5);
      expect(map['especieVegetalActual'], 'Piña');
      expect(map['estadoLote'], 'ACTIVO');
    });

    test('toMap incluye campos opcionales cuando existen', () {
      final map = loteCompleto.toMap();

      expect(map['codigoLote'], 'LN-01');
      expect(map['variedadActual'], 'Perolera');
      expect(map['observaciones'], 'Lote de mayor productividad');
    });

    test('toMap campos opcionales son null cuando no se proveen', () {
      final map = loteSinOpcionales.toMap();

      expect(map['codigoLote'], isNull);
      expect(map['variedadActual'], isNull);
      expect(map['observaciones'], isNull);
    });

    test('fromMap reconstruye el lote correctamente', () {
      final map = {
        'loteId': 'lot_001',
        'predioId': 'pred_001',
        'productorId': 'uid_123',
        'nombreLote': 'Lote Norte',
        'codigoLote': 'LN-01',
        'areaHectareas': 6.5,
        'especieVegetalActual': 'Piña',
        'variedadActual': 'Perolera',
        'estadoLote': 'ACTIVO',
        'observaciones': 'Lote de mayor productividad',
        'createdAt': null,
        'updatedAt': null,
      };

      final lote = Lote.fromMap(map);

      expect(lote.loteId, 'lot_001');
      expect(lote.predioId, 'pred_001');
      expect(lote.productorId, 'uid_123');
      expect(lote.nombreLote, 'Lote Norte');
      expect(lote.codigoLote, 'LN-01');
      expect(lote.areaHectareas, 6.5);
      expect(lote.especieVegetalActual, 'Piña');
      expect(lote.variedadActual, 'Perolera');
      expect(lote.estadoLote, 'ACTIVO');
    });

    test('fromMap usa ACTIVO como estadoLote por defecto', () {
      final map = {
        'loteId': 'lot_003',
        'predioId': 'pred_001',
        'productorId': 'uid_123',
        'nombreLote': 'Lote Este',
        'areaHectareas': 2.0,
        'especieVegetalActual': 'Cacao',
      };

      final lote = Lote.fromMap(map);
      expect(lote.estadoLote, 'ACTIVO');
    });

    test('fromMap maneja areaHectareas como entero correctamente', () {
      final map = {
        'loteId': 'lot_004',
        'predioId': 'pred_001',
        'productorId': 'uid_123',
        'nombreLote': 'Lote Oeste',
        'areaHectareas': 4,
        'especieVegetalActual': 'Yuca',
        'estadoLote': 'ACTIVO',
      };

      final lote = Lote.fromMap(map);
      expect(lote.areaHectareas, 4.0);
      expect(lote.areaHectareas, isA<double>());
    });
  });
}