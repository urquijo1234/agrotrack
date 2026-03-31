import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile_app/features/lotes/data/repositories/lotes_repository.dart';
import 'package:mobile_app/features/lotes/data/services/lotes_service.dart';
import 'package:mobile_app/features/lotes/domain/models/lote.dart';

@GenerateMocks([LotesService])
import 'lote_flow_test.mocks.dart';

void main() {
  late LotesRepository repository;
  late MockLotesService mockService;

  final loteTest = Lote(
    loteId: 'lot_001',
    predioId: 'pred_001',
    productorId: 'uid_123',
    nombreLote: 'Lote Norte',
    codigoLote: 'LN-01',
    areaHectareas: 6.5,
    especieVegetalActual: 'Piña',
    variedadActual: 'Perolera',
    estadoLote: 'ACTIVO',
    observaciones: 'Lote principal',
  );

  setUp(() {
    mockService = MockLotesService();
    repository = LotesRepository(service: mockService);
  });

  // ==========================================
  // FLUJO CREAR LOTE
  // ==========================================
  group('Flujo crear lote', () {
    test('crea lote correctamente', () async {
      // Arrange
      when(mockService.createLote(any))
          .thenAnswer((_) async => {});

      // Act
      await repository.createLote(loteTest);

      // Assert
      verify(mockService.createLote(any)).called(1);
    });

    test('falla si el servicio lanza excepcion', () async {
      // Arrange
      when(mockService.createLote(any))
          .thenThrow(Exception('Error de red'));

      // Act & Assert
      expect(
        () => repository.createLote(loteTest),
        throwsException,
      );
    });
  });

  // ==========================================
  // FLUJO LISTAR LOTES
  // ==========================================
  group('Flujo listar lotes por predio', () {
    test('retorna lotes del predio correctamente', () async {
      // Arrange
      when(mockService.getLotesByPredio(
        predioId: anyNamed('predioId'),
        productorId: anyNamed('productorId'),
      )).thenAnswer((_) async => [loteTest]);

      // Act
      final lotes = await repository.getLotesByPredio(
        predioId: 'pred_001',
        productorId: 'uid_123',
      );

      // Assert
      expect(lotes, isNotEmpty);
      expect(lotes.length, 1);
      expect(lotes.first.nombreLote, 'Lote Norte');
    });

    test('retorna lista vacia si no hay lotes', () async {
      // Arrange
      when(mockService.getLotesByPredio(
        predioId: anyNamed('predioId'),
        productorId: anyNamed('productorId'),
      )).thenAnswer((_) async => []);

      // Act
      final lotes = await repository.getLotesByPredio(
        predioId: 'pred_999',
        productorId: 'uid_123',
      );

      // Assert
      expect(lotes, isEmpty);
    });
  });

  // ==========================================
  // FLUJO ACTUALIZAR LOTE
  // ==========================================
  group('Flujo actualizar lote', () {
    test('actualiza lote correctamente', () async {
      // Arrange
      when(mockService.updateLote(any))
          .thenAnswer((_) async => {});

      // Act
      await repository.updateLote(loteTest);

      // Assert
      verify(mockService.updateLote(any)).called(1);
    });

    test('archiva lote correctamente', () async {
      // Arrange
      when(mockService.updateEstadoLote(
        loteId: anyNamed('loteId'),
        estadoLote: anyNamed('estadoLote'),
      )).thenAnswer((_) async => {});

      // Act
      await repository.updateEstadoLote(
        loteId: 'lot_001',
        estadoLote: 'ARCHIVADO',
      );

      // Assert
      verify(mockService.updateEstadoLote(
        loteId: 'lot_001',
        estadoLote: 'ARCHIVADO',
      )).called(1);
    });

    test('activa lote correctamente', () async {
      // Arrange
      when(mockService.updateEstadoLote(
        loteId: anyNamed('loteId'),
        estadoLote: anyNamed('estadoLote'),
      )).thenAnswer((_) async => {});

      // Act
      await repository.updateEstadoLote(
        loteId: 'lot_001',
        estadoLote: 'ACTIVO',
      );

      // Assert
      verify(mockService.updateEstadoLote(
        loteId: 'lot_001',
        estadoLote: 'ACTIVO',
      )).called(1);
    });
  });
}