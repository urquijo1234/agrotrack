import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile_app/features/predios/data/repositories/predios_repository.dart';
import 'package:mobile_app/features/predios/data/services/predios_service.dart';
import 'package:mobile_app/features/predios/domain/models/predio.dart';

@GenerateMocks([PrediosService])
import 'predio_flow_test.mocks.dart';

void main() {
  late PrediosRepository repository;
  late MockPrediosService mockService;

  final predioTest = Predio(
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

  setUp(() {
    mockService = MockPrediosService();
    repository = PrediosRepository(service: mockService);
  });

  // ==========================================
  // FLUJO CREAR PREDIO
  // ==========================================
  group('Flujo crear predio', () {
    test('crea predio correctamente', () async {
      // Arrange
      when(mockService.createPredio(any))
          .thenAnswer((_) async => {});

      // Act
      await repository.createPredio(predioTest);

      // Assert
      verify(mockService.createPredio(any)).called(1);
    });

    test('falla si el servicio lanza excepcion', () async {
      // Arrange
      when(mockService.createPredio(any))
          .thenThrow(Exception('Error de red'));

      // Act & Assert
      expect(
        () => repository.createPredio(predioTest),
        throwsException,
      );
    });
  });

  // ==========================================
  // FLUJO LISTAR PREDIOS
  // ==========================================
  group('Flujo listar predios', () {
    test('retorna lista de predios del productor', () async {
      // Arrange
      when(mockService.getPrediosByProductor(any))
          .thenAnswer((_) async => [predioTest]);

      // Act
      final predios = await repository.getPrediosByProductor('uid_123');

      // Assert
      expect(predios, isNotEmpty);
      expect(predios.length, 1);
      expect(predios.first.nombrePredio, 'Finca El Porvenir');
    });

    test('retorna lista vacia si no hay predios', () async {
      // Arrange
      when(mockService.getPrediosByProductor(any))
          .thenAnswer((_) async => []);

      // Act
      final predios = await repository.getPrediosByProductor('uid_123');

      // Assert
      expect(predios, isEmpty);
    });
  });

  // ==========================================
  // FLUJO ACTUALIZAR PREDIO
  // ==========================================
  group('Flujo actualizar predio', () {
    test('actualiza predio correctamente', () async {
      // Arrange
      when(mockService.updatePredio(any))
          .thenAnswer((_) async => {});

      // Act
      await repository.updatePredio(predioTest);

      // Assert
      verify(mockService.updatePredio(any)).called(1);
    });

    test('actualiza estado del predio correctamente', () async {
      // Arrange
      when(mockService.updateEstadoPredio(
        predioId: anyNamed('predioId'),
        estadoPredio: anyNamed('estadoPredio'),
      )).thenAnswer((_) async => {});

      // Act
      await repository.updateEstadoPredio(
        predioId: 'pred_001',
        estadoPredio: 'ARCHIVADO',
      );

      // Assert
      verify(mockService.updateEstadoPredio(
        predioId: 'pred_001',
        estadoPredio: 'ARCHIVADO',
      )).called(1);
    });
  });
}