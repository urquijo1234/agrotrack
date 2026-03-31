import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile_app/features/eventos_agricolas/data/repositories/eventos_repository.dart';
import 'package:mobile_app/features/eventos_agricolas/data/services/eventos_firebase_service.dart';
import 'package:mobile_app/features/eventos_agricolas/domain/models/evento_agricola.dart';
import 'package:mobile_app/core/services/sqlite_service.dart';
import 'package:sqflite/sqflite.dart';

@GenerateMocks([EventosFirebaseService, SqliteService, Database])
import 'eventos_repository_test.mocks.dart';

void main() {
  late EventosRepository repository;
  late MockEventosFirebaseService mockFirebaseService;
  late MockSqliteService mockSqliteService;
  late MockDatabase mockDatabase;

  final fechaEvento = DateTime(2026, 3, 10);

  final eventoTest = EventoAgricola(
    eventoId: '',
    loteId: 'lot_001',
    predioId: 'pred_001',
    productorId: 'uid_123',
    tipoEvento: TipoEvento.SIEMBRA,
    fechaEvento: fechaEvento,
    descripcion: 'Siembra de prueba',
    detalleEvento: {
      'especieVegetal': 'Piña',
      'cantidadSembrada': 500.0,
      'unidadCantidad': 'plantas',
      'areaSembradaHa': 2.5,
    },
    isSynced: false,
    createdAt: fechaEvento,
    updatedAt: fechaEvento,
  );

  setUp(() {
    mockFirebaseService = MockEventosFirebaseService();
    mockSqliteService = MockSqliteService();
    mockDatabase = MockDatabase();

    // SQLite siempre retorna el mock de database
    when(mockSqliteService.database)
        .thenAnswer((_) async => mockDatabase);

    repository = EventosRepository(
      firebaseService: mockFirebaseService,
      sqliteService: mockSqliteService,
    );
  });

  // ==========================================
  // CREAR EVENTO
  // ==========================================
  group('createEvento', () {
    test('guarda el evento en SQLite correctamente', () async {
      // Arrange
      when(mockDatabase.insert(
        any,
        any,
        conflictAlgorithm: anyNamed('conflictAlgorithm'),
      )).thenAnswer((_) async => 1);

      when(mockFirebaseService.pushEvento(any))
          .thenAnswer((_) async => {});

      when(mockDatabase.update(
        any,
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => 1);

      // Act
      await repository.createEvento(eventoTest);

      // Assert — verifica que se insertó en SQLite
      verify(mockDatabase.insert(
        'eventos_locales',
        any,
        conflictAlgorithm: anyNamed('conflictAlgorithm'),
      )).called(1);
    });

    test('el evento se guarda con isSynced false inicialmente', () async {
      // Arrange
      Map<String, dynamic>? capturedMap;

      when(mockDatabase.insert(
        any,
        any,
        conflictAlgorithm: anyNamed('conflictAlgorithm'),
      )).thenAnswer((invocation) async {
        capturedMap = invocation.positionalArguments[1] as Map<String, dynamic>;
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

      // Act
      await repository.createEvento(eventoTest);

      // Assert
      expect(capturedMap?['isSynced'], 0);
    });

    test('genera un eventoId cuando viene vacio', () async {
      // Arrange
      Map<String, dynamic>? capturedMap;

      when(mockDatabase.insert(
        any,
        any,
        conflictAlgorithm: anyNamed('conflictAlgorithm'),
      )).thenAnswer((invocation) async {
        capturedMap = invocation.positionalArguments[1] as Map<String, dynamic>;
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

      // Act
      await repository.createEvento(eventoTest);

      // Assert — el ID no debe estar vacío
      expect(capturedMap?['eventoId'], isNotEmpty);
    });
  });

  // ==========================================
  // LEER EVENTOS
  // ==========================================
  group('getEventosByLote', () {
    test('retorna lista de eventos desde SQLite', () async {
      // Arrange
      final fechaStr = fechaEvento.toIso8601String();
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
              'descripcion': 'Siembra de prueba',
              'detalleEvento': '{"especieVegetal":"Piña"}',
              'isSynced': 0,
              'createdAt': fechaStr,
              'updatedAt': fechaStr,
            }
          ]);

      // Act
      final eventos = await repository.getEventosByLote('lot_001');

      // Assert
      expect(eventos, isNotEmpty);
      expect(eventos.length, 1);
      expect(eventos.first.loteId, 'lot_001');
      expect(eventos.first.tipoEvento, TipoEvento.SIEMBRA);
    });

    test('retorna lista vacia cuando no hay eventos', () async {
      // Arrange
      when(mockDatabase.query(
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
        orderBy: anyNamed('orderBy'),
      )).thenAnswer((_) async => []);

      // Act
      final eventos = await repository.getEventosByLote('lot_999');

      // Assert
      expect(eventos, isEmpty);
    });
  });

  // ==========================================
  // SINCRONIZACION
  // ==========================================
  group('syncPendingEvents', () {
    test('sincroniza eventos pendientes y los marca como sincronizados',
        () async {
      // Arrange
      final fechaStr = fechaEvento.toIso8601String();
      when(mockDatabase.query(
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => [
            {
              'eventoId': 'evt_001',
              'loteId': 'lot_001',
              'predioId': 'pred_001',
              'productorId': 'uid_123',
              'tipoEvento': 'SIEMBRA',
              'fechaEvento': fechaStr,
              'descripcion': 'Siembra pendiente',
              'detalleEvento': '{"especieVegetal":"Piña"}',
              'isSynced': 0,
              'createdAt': fechaStr,
              'updatedAt': fechaStr,
            }
          ]);

      when(mockFirebaseService.pushEvento(any))
          .thenAnswer((_) async => {});

      when(mockDatabase.update(
        any,
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => 1);

      // Act
      await repository.syncPendingEvents();

      // Assert — se intentó subir a Firebase
      verify(mockFirebaseService.pushEvento(any)).called(1);

      // Assert — se marcó como sincronizado en SQLite
      verify(mockDatabase.update(
        'eventos_locales',
        argThat(containsPair('isSynced', 1)),
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).called(1);
    });

    test('continua sincronizando si un evento falla', () async {
      // Arrange
      final fechaStr = fechaEvento.toIso8601String();
      when(mockDatabase.query(
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => [
            {
              'eventoId': 'evt_001',
              'loteId': 'lot_001',
              'predioId': 'pred_001',
              'productorId': 'uid_123',
              'tipoEvento': 'SIEMBRA',
              'fechaEvento': fechaStr,
              'descripcion': 'Evento que falla',
              'detalleEvento': '{"especieVegetal":"Piña"}',
              'isSynced': 0,
              'createdAt': fechaStr,
              'updatedAt': fechaStr,
            },
            {
              'eventoId': 'evt_002',
              'loteId': 'lot_001',
              'predioId': 'pred_001',
              'productorId': 'uid_123',
              'tipoEvento': 'COSECHA',
              'fechaEvento': fechaStr,
              'descripcion': 'Evento que si sube',
              'detalleEvento': '{"cantidadCosechada":100}',
              'isSynced': 0,
              'createdAt': fechaStr,
              'updatedAt': fechaStr,
            }
          ]);

      // --- SOLUCIÓN AL ERROR DE VOID ---
      int count = 0;
      when(mockFirebaseService.pushEvento(any)).thenAnswer((_) async {
        count++;
        if (count == 1) {
          throw Exception('Sin conexión');
        }
        return; // Retorna void exitosamente la segunda vez
      });

      when(mockDatabase.update(
        any,
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => 1);

      // Act — no debe lanzar excepción
      await expectLater(
        repository.syncPendingEvents(),
        completes,
      );
      
      // Verificamos que se llamó 2 veces a pesar del fallo del primero
      verify(mockFirebaseService.pushEvento(any)).called(2);
    });
  });

  // ==========================================
  // CONTADOR DE PENDIENTES
  // ==========================================
  group('getPendingSyncCount', () {
    test('retorna el numero correcto de eventos pendientes', () async {
      // Arrange
      when(mockDatabase.rawQuery(any))
          .thenAnswer((_) async => [
                {'COUNT(*)': 3}
              ]);

      // Act
      final count = await repository.getPendingSyncCount();

      // Assert
      expect(count, 3);
    });

    test('retorna 0 cuando no hay eventos pendientes', () async {
      // Arrange
      when(mockDatabase.rawQuery(any))
          .thenAnswer((_) async => [
                {'COUNT(*)': 0}
              ]);

      // Act
      final count = await repository.getPendingSyncCount();

      // Assert
      expect(count, 0);
    });
  });
}