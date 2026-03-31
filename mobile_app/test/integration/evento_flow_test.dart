import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile_app/features/eventos_agricolas/data/repositories/eventos_repository.dart';
import 'package:mobile_app/features/eventos_agricolas/data/services/eventos_firebase_service.dart';
import 'package:mobile_app/features/eventos_agricolas/domain/models/evento_agricola.dart';
import 'package:mobile_app/core/services/sqlite_service.dart';
import 'package:sqflite/sqflite.dart';

@GenerateMocks([EventosFirebaseService, SqliteService, Database])
import 'evento_flow_test.mocks.dart';

void main() {
  late EventosRepository repository;
  late MockEventosFirebaseService mockFirebaseService;
  late MockSqliteService mockSqliteService;
  late MockDatabase mockDatabase;

  final fechaEvento = DateTime(2026, 3, 10);
  final fechaStr = fechaEvento.toIso8601String();

  setUp(() {
    mockFirebaseService = MockEventosFirebaseService();
    mockSqliteService = MockSqliteService();
    mockDatabase = MockDatabase();

    when(mockSqliteService.database)
        .thenAnswer((_) async => mockDatabase);

    repository = EventosRepository(
      firebaseService: mockFirebaseService,
      sqliteService: mockSqliteService,
    );
  });

  // ==========================================
  // FLUJO COMPLETO SIEMBRA
  // ==========================================
  group('Flujo completo siembra', () {
    test('registra siembra y queda pendiente de sync', () async {
      // Arrange
      Map<String, dynamic>? capturedMap;

      when(mockDatabase.insert(
        any,
        any,
        conflictAlgorithm: anyNamed('conflictAlgorithm'),
      )).thenAnswer((invocation) async {
        capturedMap = invocation.positionalArguments[1];
        return 1;
      });

      when(mockFirebaseService.pushEvento(any))
          .thenAnswer((_) async => {});

      when(mockDatabase.update(
        any,
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => 1);

      final evento = EventoAgricola(
        eventoId: '',
        loteId: 'lot_001',
        predioId: 'pred_001',
        productorId: 'uid_123',
        tipoEvento: TipoEvento.SIEMBRA,
        fechaEvento: fechaEvento,
        descripcion: 'Siembra de Piña',
        detalleEvento: {
          'especieVegetal': 'Piña',
          'cantidadSembrada': 500.0,
          'unidadCantidad': 'plantas',
          'areaSembradaHa': 2.5,
        },
      );

      // Act
      await repository.createEvento(evento);

      // Assert
      expect(capturedMap?['tipoEvento'], 'SIEMBRA');
      expect(capturedMap?['loteId'], 'lot_001');
      expect(capturedMap?['isSynced'], 0);
      expect(capturedMap?['eventoId'], isNotEmpty);
    });
  });

  // ==========================================
  // FLUJO COMPLETO INSUMO
  // ==========================================
  group('Flujo completo insumo', () {
    test('registra aplicacion de insumo correctamente', () async {
      // Arrange
      Map<String, dynamic>? capturedMap;

      when(mockDatabase.insert(
        any,
        any,
        conflictAlgorithm: anyNamed('conflictAlgorithm'),
      )).thenAnswer((invocation) async {
        capturedMap = invocation.positionalArguments[1];
        return 1;
      });

      when(mockFirebaseService.pushEvento(any))
          .thenAnswer((_) async => {});

      when(mockDatabase.update(
        any,
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => 1);

      final evento = EventoAgricola(
        eventoId: '',
        loteId: 'lot_001',
        predioId: 'pred_001',
        productorId: 'uid_123',
        tipoEvento: TipoEvento.APLICACION_INSUMO,
        fechaEvento: fechaEvento,
        descripcion: 'Fertilización NPK',
        detalleEvento: {
          'tipoInsumo': 'Fertilizante',
          'nombreInsumo': 'NPK 15-15-15',
          'dosis': 50.0,
          'unidadDosis': 'kg/ha',
          'metodoAplicacion': 'Manual',
          'areaTratadaHa': 1.8,
        },
      );

      // Act
      await repository.createEvento(evento);

      // Assert
      expect(capturedMap?['tipoEvento'], 'APLICACION_INSUMO');
      expect(capturedMap?['isSynced'], 0);
    });
  });

  // ==========================================
  // FLUJO COMPLETO COSECHA
  // ==========================================
  group('Flujo completo cosecha', () {
    test('registra cosecha correctamente', () async {
      // Arrange
      Map<String, dynamic>? capturedMap;

      when(mockDatabase.insert(
        any,
        any,
        conflictAlgorithm: anyNamed('conflictAlgorithm'),
      )).thenAnswer((invocation) async {
        capturedMap = invocation.positionalArguments[1];
        return 1;
      });

      when(mockFirebaseService.pushEvento(any))
          .thenAnswer((_) async => {});

      when(mockDatabase.update(
        any,
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => 1);

      final evento = EventoAgricola(
        eventoId: '',
        loteId: 'lot_001',
        predioId: 'pred_001',
        productorId: 'uid_123',
        tipoEvento: TipoEvento.COSECHA,
        fechaEvento: fechaEvento,
        descripcion: 'Cosecha de Piña',
        detalleEvento: {
          'especieVegetal': 'Piña',
          'cantidadCosechada': 1200.0,
          'unidadProduccion': 'kg',
          'areaCosechadaHa': 2.5,
        },
      );

      // Act
      await repository.createEvento(evento);

      // Assert
      expect(capturedMap?['tipoEvento'], 'COSECHA');
      expect(capturedMap?['isSynced'], 0);
    });
  });

  // ==========================================
  // FLUJO HISTORIAL DEL LOTE
  // ==========================================
  group('Flujo historial del lote', () {
    test('retorna historial completo ordenado por fecha', () async {
      // Arrange
      when(mockDatabase.query(
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
        orderBy: anyNamed('orderBy'),
      )).thenAnswer((_) async => [
            {
              'eventoId': 'evt_001',
              'loteId': 'lot_001',
              'predioId': 'pred_001',
              'productorId': 'uid_123',
              'tipoEvento': 'SIEMBRA',
              'fechaEvento': fechaStr,
              'descripcion': 'Siembra inicial',
              'detalleEvento': '{"especieVegetal":"Piña"}',
              'isSynced': 1,
              'createdAt': fechaStr,
              'updatedAt': fechaStr,
            },
            {
              'eventoId': 'evt_002',
              'loteId': 'lot_001',
              'predioId': 'pred_001',
              'productorId': 'uid_123',
              'tipoEvento': 'APLICACION_INSUMO',
              'fechaEvento': fechaStr,
              'descripcion': 'Fertilización',
              'detalleEvento': '{"tipoInsumo":"Fertilizante"}',
              'isSynced': 0,
              'createdAt': fechaStr,
              'updatedAt': fechaStr,
            },
          ]);

      // Act
      final eventos = await repository.getEventosByLote('lot_001');

      // Assert
      expect(eventos.length, 2);
      expect(eventos[0].tipoEvento, TipoEvento.SIEMBRA);
      expect(eventos[1].tipoEvento, TipoEvento.APLICACION_INSUMO);
      expect(eventos[0].isSynced, true);
      expect(eventos[1].isSynced, false);
    });
  });
}