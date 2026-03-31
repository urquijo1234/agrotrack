import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/eventos_agricolas/domain/models/evento_agricola.dart';

void main() {
  group('EventoAgricola', () {
    final fechaEvento = DateTime(2026, 3, 10);

    // ==========================================
    // EVENTO DE SIEMBRA
    // ==========================================
    final eventoSiembra = EventoAgricola(
      eventoId: 'evt_001',
      loteId: 'lot_001',
      predioId: 'pred_001',
      productorId: 'uid_123',
      tipoEvento: TipoEvento.SIEMBRA,
      fechaEvento: fechaEvento,
      descripcion: 'Siembra de Piña',
      detalleEvento: {
        'especieVegetal': 'Piña',
        'variedad': 'Perolera',
        'fechaSiembra': fechaEvento.toIso8601String(),
        'cantidadSembrada': 500.0,
        'unidadCantidad': 'plantas',
        'areaSembradaHa': 2.5,
        'origenSemilla': 'Local',
        'observaciones': 'Siembra en época seca',
      },
      isSynced: false,
      createdAt: fechaEvento,
      updatedAt: fechaEvento,
    );

    // ==========================================
    // EVENTO DE APLICACION DE INSUMO
    // ==========================================
    final eventoInsumo = EventoAgricola(
      eventoId: 'evt_002',
      loteId: 'lot_001',
      predioId: 'pred_001',
      productorId: 'uid_123',
      tipoEvento: TipoEvento.APLICACION_INSUMO,
      fechaEvento: fechaEvento,
      descripcion: 'Fertilización NPK',
      detalleEvento: {
        'tipoInsumo': 'Fertilizante',
        'nombreInsumo': 'NPK 15-15-15',
        'ingredienteActivo': 'NPK',
        'dosis': 50.0,
        'unidadDosis': 'kg/ha',
        'metodoAplicacion': 'Manual',
        'areaTratadaHa': 1.8,
        'responsableAplicacion': 'Luis Gómez',
        'motivoAplicacion': 'Nutrición',
      },
      isSynced: false,
      createdAt: fechaEvento,
      updatedAt: fechaEvento,
    );

    // ==========================================
    // EVENTO DE COSECHA
    // ==========================================
    final eventoCosecha = EventoAgricola(
      eventoId: 'evt_003',
      loteId: 'lot_001',
      predioId: 'pred_001',
      productorId: 'uid_123',
      tipoEvento: TipoEvento.COSECHA,
      fechaEvento: fechaEvento,
      descripcion: 'Cosecha de Piña',
      detalleEvento: {
        'especieVegetal': 'Piña',
        'fechaCosecha': fechaEvento.toIso8601String(),
        'cantidadCosechada': 1200.0,
        'unidadProduccion': 'kg',
        'areaCosechadaHa': 2.5,
        'destinoProduccion': 'Mercado local',
        'responsableCosecha': 'Luis Gómez',
      },
      isSynced: true,
      createdAt: fechaEvento,
      updatedAt: fechaEvento,
    );

    // ==========================================
    // TESTS SIEMBRA
    // ==========================================
    group('Siembra - toSqliteMap', () {
      test('serializa correctamente a SQLite', () {
        final map = eventoSiembra.toSqliteMap();

        expect(map['eventoId'], 'evt_001');
        expect(map['loteId'], 'lot_001');
        expect(map['predioId'], 'pred_001');
        expect(map['productorId'], 'uid_123');
        expect(map['tipoEvento'], 'SIEMBRA');
        expect(map['isSynced'], 0);
      });

      test('detalleEvento se serializa como JSON string en SQLite', () {
        final map = eventoSiembra.toSqliteMap();
        expect(map['detalleEvento'], isA<String>());
        expect(map['detalleEvento'], contains('Piña'));
      });

      test('isSynced false se guarda como 0 en SQLite', () {
        final map = eventoSiembra.toSqliteMap();
        expect(map['isSynced'], 0);
      });
    });

    group('Siembra - fromSqliteMap', () {
      test('reconstruye correctamente desde SQLite', () {
        final map = eventoSiembra.toSqliteMap();
        final reconstruido = EventoAgricola.fromSqliteMap(map);

        expect(reconstruido.eventoId, 'evt_001');
        expect(reconstruido.loteId, 'lot_001');
        expect(reconstruido.tipoEvento, TipoEvento.SIEMBRA);
        expect(reconstruido.isSynced, false);
      });

      test('detalleEvento se deserializa correctamente desde SQLite', () {
        final map = eventoSiembra.toSqliteMap();
        final reconstruido = EventoAgricola.fromSqliteMap(map);

        expect(reconstruido.detalleEvento['especieVegetal'], 'Piña');
        expect(reconstruido.detalleEvento['cantidadSembrada'], 500.0);
        expect(reconstruido.detalleEvento['unidadCantidad'], 'plantas');
      });
    });

    // ==========================================
    // TESTS APLICACION INSUMO
    // ==========================================
    group('Aplicacion Insumo - toSqliteMap y fromSqliteMap', () {
      test('serializa y deserializa correctamente', () {
        final map = eventoInsumo.toSqliteMap();
        final reconstruido = EventoAgricola.fromSqliteMap(map);

        expect(reconstruido.tipoEvento, TipoEvento.APLICACION_INSUMO);
        expect(reconstruido.detalleEvento['tipoInsumo'], 'Fertilizante');
        expect(reconstruido.detalleEvento['nombreInsumo'], 'NPK 15-15-15');
        expect(reconstruido.detalleEvento['dosis'], 50.0);
        expect(reconstruido.detalleEvento['unidadDosis'], 'kg/ha');
      });
    });

    // ==========================================
    // TESTS COSECHA
    // ==========================================
    group('Cosecha - toSqliteMap y fromSqliteMap', () {
      test('serializa y deserializa correctamente', () {
        final map = eventoCosecha.toSqliteMap();
        final reconstruido = EventoAgricola.fromSqliteMap(map);

        expect(reconstruido.tipoEvento, TipoEvento.COSECHA);
        expect(reconstruido.detalleEvento['cantidadCosechada'], 1200.0);
        expect(reconstruido.detalleEvento['unidadProduccion'], 'kg');
        expect(reconstruido.detalleEvento['destinoProduccion'], 'Mercado local');
      });

      test('isSynced true se guarda como 1 en SQLite', () {
        final map = eventoCosecha.toSqliteMap();
        expect(map['isSynced'], 1);
      });

      test('isSynced true se reconstruye correctamente desde SQLite', () {
        final map = eventoCosecha.toSqliteMap();
        final reconstruido = EventoAgricola.fromSqliteMap(map);
        expect(reconstruido.isSynced, true);
      });
    });

    // ==========================================
    // TESTS COPYWITH
    // ==========================================
    group('copyWith', () {
      test('actualiza isSynced correctamente', () {
        final actualizado = eventoSiembra.copyWith(isSynced: true);
        expect(actualizado.isSynced, true);
        expect(actualizado.eventoId, eventoSiembra.eventoId);
        expect(actualizado.loteId, eventoSiembra.loteId);
      });

      test('mantiene los demas campos intactos al copiar', () {
        final actualizado = eventoSiembra.copyWith(isSynced: true);
        expect(actualizado.tipoEvento, TipoEvento.SIEMBRA);
        expect(actualizado.detalleEvento['especieVegetal'], 'Piña');
      });

      test('actualiza updatedAt correctamente', () {
        final nuevaFecha = DateTime(2026, 4, 1);
        final actualizado = eventoSiembra.copyWith(updatedAt: nuevaFecha);
        expect(actualizado.updatedAt, nuevaFecha);
      });
    });

    // ==========================================
    // TESTS GENERALES
    // ==========================================
    group('General', () {
      test('fechaEvento se preserva correctamente en ciclo SQLite', () {
        final map = eventoSiembra.toSqliteMap();
        final reconstruido = EventoAgricola.fromSqliteMap(map);
        expect(reconstruido.fechaEvento, fechaEvento);
      });

      test('descripcion opcional se preserva correctamente', () {
        final map = eventoSiembra.toSqliteMap();
        final reconstruido = EventoAgricola.fromSqliteMap(map);
        expect(reconstruido.descripcion, 'Siembra de Piña');
      });

      test('evento sin descripcion no falla', () {
        final eventoSinDesc = EventoAgricola(
          eventoId: 'evt_004',
          loteId: 'lot_001',
          predioId: 'pred_001',
          productorId: 'uid_123',
          tipoEvento: TipoEvento.SIEMBRA,
          fechaEvento: fechaEvento,
          detalleEvento: {'especieVegetal': 'Maíz'},
        );

        final map = eventoSinDesc.toSqliteMap();
        final reconstruido = EventoAgricola.fromSqliteMap(map);
        expect(reconstruido.descripcion, isNull);
      });
    });
  });
}