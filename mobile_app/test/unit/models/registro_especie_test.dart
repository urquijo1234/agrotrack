import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/informes/domain/models/registro_especie.dart';

void main() {
  group('RegistroEspecie', () {
    final fechaSiembra = DateTime(2026, 1, 15);

    final registroCompleto = RegistroEspecie(
      registroId: 'reg_001',
      especieVegetal: 'Piña',
      numeroLotesOTotes: 14,
      variedad: 'Perolera',
      fechaSiembra: fechaSiembra,
      numeroPlantas: 3575000,
      fenologia: 'Fructificación',
      estadoFitosanitario: 'Bueno',
      produccionEstimada: 200000.0,
      unidadProduccion: 'piñas/mes',
      frecuenciaMonitoreo: 'Mensual',
      porcentajeArea: 30.0,
    );

    final registroMinimo = RegistroEspecie(
      registroId: 'reg_002',
      especieVegetal: 'Mango',
    );

    // ==========================================
    // TESTS toMap
    // ==========================================
    group('toMap', () {
      test('serializa todos los campos correctamente', () {
        final map = registroCompleto.toMap();

        expect(map['registroId'], 'reg_001');
        expect(map['especieVegetal'], 'Piña');
        expect(map['numeroLotesOTotes'], 14);
        expect(map['variedad'], 'Perolera');
        expect(map['numeroPlantas'], 3575000);
        expect(map['fenologia'], 'Fructificación');
        expect(map['estadoFitosanitario'], 'Bueno');
        expect(map['produccionEstimada'], 200000.0);
        expect(map['unidadProduccion'], 'piñas/mes');
        expect(map['frecuenciaMonitoreo'], 'Mensual');
        expect(map['porcentajeArea'], 30.0);
      });

      test('serializa fechaSiembra como ISO string', () {
        final map = registroCompleto.toMap();
        expect(map['fechaSiembra'], isA<String>());
        expect(map['fechaSiembra'], fechaSiembra.toIso8601String());
      });

      test('campos opcionales son null en registro mínimo', () {
        final map = registroMinimo.toMap();

        expect(map['registroId'], 'reg_002');
        expect(map['especieVegetal'], 'Mango');
        expect(map['variedad'], isNull);
        expect(map['numeroLotesOTotes'], isNull);
        expect(map['fechaSiembra'], isNull);
        expect(map['numeroPlantas'], isNull);
        expect(map['produccionEstimada'], isNull);
      });
    });

    // ==========================================
    // TESTS fromMap
    // ==========================================
    group('fromMap', () {
      test('reconstruye registro completo correctamente', () {
        final map = registroCompleto.toMap();
        final reconstruido = RegistroEspecie.fromMap(map);

        expect(reconstruido.registroId, 'reg_001');
        expect(reconstruido.especieVegetal, 'Piña');
        expect(reconstruido.variedad, 'Perolera');
        expect(reconstruido.numeroPlantas, 3575000);
        expect(reconstruido.fenologia, 'Fructificación');
        expect(reconstruido.produccionEstimada, 200000.0);
        expect(reconstruido.unidadProduccion, 'piñas/mes');
        expect(reconstruido.porcentajeArea, 30.0);
      });

      test('reconstruye fechaSiembra correctamente', () {
        final map = registroCompleto.toMap();
        final reconstruido = RegistroEspecie.fromMap(map);
        expect(reconstruido.fechaSiembra, fechaSiembra);
      });

      test('reconstruye registro mínimo sin errores', () {
        final map = {
          'registroId': 'reg_003',
          'especieVegetal': 'Cacao',
        };

        final reconstruido = RegistroEspecie.fromMap(map);
        expect(reconstruido.registroId, 'reg_003');
        expect(reconstruido.especieVegetal, 'Cacao');
        expect(reconstruido.variedad, isNull);
        expect(reconstruido.fechaSiembra, isNull);
        expect(reconstruido.numeroPlantas, isNull);
      });

      test('maneja produccionEstimada como entero correctamente', () {
        final map = {
          'registroId': 'reg_004',
          'especieVegetal': 'Yuca',
          'produccionEstimada': 500,
        };

        final reconstruido = RegistroEspecie.fromMap(map);
        expect(reconstruido.produccionEstimada, 500.0);
        expect(reconstruido.produccionEstimada, isA<double>());
      });

      test('fechaSiembra null no lanza error', () {
        final map = {
          'registroId': 'reg_005',
          'especieVegetal': 'Plátano',
          'fechaSiembra': null,
        };

        final reconstruido = RegistroEspecie.fromMap(map);
        expect(reconstruido.fechaSiembra, isNull);
      });
    });

    // ==========================================
    // TESTS ciclo completo
    // ==========================================
    group('Ciclo toMap → fromMap', () {
      test('preserva todos los campos en ciclo completo', () {
        final map = registroCompleto.toMap();
        final reconstruido = RegistroEspecie.fromMap(map);

        expect(reconstruido.registroId, registroCompleto.registroId);
        expect(
            reconstruido.especieVegetal, registroCompleto.especieVegetal);
        expect(reconstruido.variedad, registroCompleto.variedad);
        expect(reconstruido.numeroLotesOTotes,
            registroCompleto.numeroLotesOTotes);
        expect(reconstruido.numeroPlantas, registroCompleto.numeroPlantas);
        expect(reconstruido.fenologia, registroCompleto.fenologia);
        expect(reconstruido.estadoFitosanitario,
            registroCompleto.estadoFitosanitario);
        expect(reconstruido.produccionEstimada,
            registroCompleto.produccionEstimada);
        expect(reconstruido.unidadProduccion,
            registroCompleto.unidadProduccion);
        expect(reconstruido.frecuenciaMonitoreo,
            registroCompleto.frecuenciaMonitoreo);
        expect(
            reconstruido.porcentajeArea, registroCompleto.porcentajeArea);
      });
    });
  });
}