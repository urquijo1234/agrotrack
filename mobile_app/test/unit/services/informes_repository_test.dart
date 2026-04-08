import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile_app/features/informes/data/repositories/informes_repository.dart';
import 'package:mobile_app/features/informes/data/services/informes_service.dart';
import 'package:mobile_app/features/informes/domain/models/informe_sanitario.dart';
import 'package:mobile_app/features/informes/domain/models/checklist_item.dart';
import 'package:mobile_app/features/informes/domain/models/checklist_respuesta.dart';
import 'package:mobile_app/features/informes/domain/models/registro_especie.dart';
import 'package:mobile_app/features/lotes/domain/models/lote.dart';
import 'package:mobile_app/features/predios/domain/models/predio.dart';
import 'package:mobile_app/features/auth/domain/models/productor.dart';

@GenerateMocks([InformesService])
import 'informes_repository_test.mocks.dart';

void main() {
  late InformesRepository repository;
  late MockInformesService mockService;

  final loteTest = Lote(
    loteId: 'lot_001',
    predioId: 'pred_001',
    productorId: 'uid_123',
    nombreLote: 'Lote Norte',
    areaHectareas: 6.5,
    especieVegetalActual: 'Piña',
    estadoLote: 'ACTIVO',
  );

  final predioTest = Predio(
    predioId: 'pred_001',
    productorId: 'uid_123',
    nombrePredio: 'Finca El Porvenir',
    departamento: 'Santander',
    municipio: 'Lebrija',
    numeroRegistroICA: 'ICA-45892',
    estadoPredio: 'ACTIVO',
  );

  final productorTest = Productor(
    productorId: 'uid_123',
    uidAuth: 'uid_123',
    nombreCompleto: 'Luis Alberto Gómez',
    correo: 'luis@correo.com',
    estadoCuenta: 'ACTIVO',
  );

  final informeTest = InformeFitosanitario(
    informeId: 'inf_001',
    loteId: 'lot_001',
    predioId: 'pred_001',
    productorId: 'uid_123',
    periodoReportado: PeriodoReportado.FEB_MAR_ABR,
    anioReporte: 2026,
    estadoInforme: EstadoInforme.BORRADOR,
    nombrePredioReportado: 'Finca El Porvenir',
    nombreTitularReportado: 'Luis Alberto Gómez',
    departamentoReportado: 'Santander',
    municipioReportado: 'Lebrija',
    numeroRegistroICA: 'ICA-45892',
    especieVegetalReportada: 'Piña',
  );

  setUp(() {
    mockService = MockInformesService();
    repository = InformesRepository(service: mockService);
  });

  // ==========================================
  // CREAR INFORME
  // ==========================================
  group('crearInforme', () {
    test('crea informe correctamente cuando no existe el periodo', () async {
      when(mockService.existeInformeParaPeriodo(
        loteId: anyNamed('loteId'),
        periodoReportado: anyNamed('periodoReportado'),
        anioReporte: anyNamed('anioReporte'),
        productorId: anyNamed('productorId'),
      )).thenAnswer((_) async => false);

      when(mockService.createInforme(any))
          .thenAnswer((_) async => 'inf_001');

      final id = await repository.crearInforme(
        lote: loteTest,
        predio: predioTest,
        productor: productorTest,
        periodo: PeriodoReportado.FEB_MAR_ABR,
        anio: 2026,
      );

      expect(id, 'inf_001');
      verify(mockService.createInforme(any)).called(1);
    });

    test('lanza excepcion si ya existe informe para ese periodo', () async {
      when(mockService.existeInformeParaPeriodo(
        loteId: anyNamed('loteId'),
        periodoReportado: anyNamed('periodoReportado'),
        anioReporte: anyNamed('anioReporte'),
        productorId: anyNamed('productorId'),
      )).thenAnswer((_) async => true);

      expect(
        () => repository.crearInforme(
          lote: loteTest,
          predio: predioTest,
          productor: productorTest,
          periodo: PeriodoReportado.FEB_MAR_ABR,
          anio: 2026,
        ),
        throwsException,
      );

      verifyNever(mockService.createInforme(any));
    });

    test('el informe creado captura snapshot del predio correctamente',
        () async {
      InformeFitosanitario? informeCapturado;

      when(mockService.existeInformeParaPeriodo(
        loteId: anyNamed('loteId'),
        periodoReportado: anyNamed('periodoReportado'),
        anioReporte: anyNamed('anioReporte'),
        productorId: anyNamed('productorId'),
      )).thenAnswer((_) async => false);

      when(mockService.createInforme(any)).thenAnswer((invocation) async {
        informeCapturado =
            invocation.positionalArguments[0] as InformeFitosanitario;
        return 'inf_001';
      });

      await repository.crearInforme(
        lote: loteTest,
        predio: predioTest,
        productor: productorTest,
        periodo: PeriodoReportado.FEB_MAR_ABR,
        anio: 2026,
      );

      expect(informeCapturado?.nombrePredioReportado,
          predioTest.nombrePredio);
      expect(informeCapturado?.nombreTitularReportado,
          productorTest.nombreCompleto);
      expect(informeCapturado?.departamentoReportado,
          predioTest.departamento);
      expect(informeCapturado?.municipioReportado, predioTest.municipio);
      expect(informeCapturado?.especieVegetalReportada,
          loteTest.especieVegetalActual);
      expect(informeCapturado?.estadoInforme, EstadoInforme.BORRADOR);
    });
  });

  // ==========================================
  // LISTAR INFORMES
  // ==========================================
  group('getInformesByLote', () {
    test('retorna lista de informes correctamente', () async {
      when(mockService.getInformesByLote(any, any))
          .thenAnswer((_) async => [informeTest]);

      final informes =
          await repository.getInformesByLote('lot_001', 'uid_123');

      expect(informes, isNotEmpty);
      expect(informes.length, 1);
      expect(informes.first.loteId, 'lot_001');
    });

    test('retorna lista vacía si no hay informes', () async {
      when(mockService.getInformesByLote(any, any))
          .thenAnswer((_) async => []);

      final informes =
          await repository.getInformesByLote('lot_999', 'uid_123');

      expect(informes, isEmpty);
    });
  });

  // ==========================================
  // CHECKLIST
  // ==========================================
  group('getChecklistCatalogo', () {
    test('retorna el catálogo de preguntas correctamente', () async {
      final catalogo = [
        ChecklistItem(
          numeroItem: 35,
          seccion: 'V',
          enunciado: 'Áreas de cultivo para la producción de vegetales',
          tieneCumple: true,
          tieneEstado: true,
          tieneSenalizado: true,
          tieneObservacion: false,
        ),
        ChecklistItem(
          numeroItem: 44,
          seccion: 'VI',
          enunciado: '¿Cuenta con el certificado de uso de suelo?',
          tieneCumple: true,
          tieneEstado: false,
          tieneSenalizado: false,
          tieneObservacion: false,
        ),
      ];

      when(mockService.getChecklistCatalogo())
          .thenAnswer((_) async => catalogo);

      final resultado = await repository.getChecklistCatalogo();

      expect(resultado.length, 2);
      expect(resultado.first.numeroItem, 35);
      expect(resultado.first.tieneEstado, true);
      expect(resultado.last.tieneEstado, false);
    });
  });

  group('guardarChecklistRespuestas', () {
    test('guarda respuestas correctamente', () async {
      when(mockService.saveChecklistRespuestas(
        informeId: anyNamed('informeId'),
        respuestas: anyNamed('respuestas'),
      )).thenAnswer((_) async => {});

      final respuestas = [
        ChecklistRespuesta(
            numeroItem: 35, seccion: 'V', cumple: true, estado: 'B'),
        ChecklistRespuesta(
            numeroItem: 44, seccion: 'VI', cumple: true),
      ];

      await repository.guardarChecklistRespuestas(
        informeId: 'inf_001',
        respuestas: respuestas,
      );

      verify(mockService.saveChecklistRespuestas(
        informeId: 'inf_001',
        respuestas: anyNamed('respuestas'),
      )).called(1);
    });
  });

  // ==========================================
  // REGISTROS DE ESPECIE
  // ==========================================
  group('guardarRegistroEspecie', () {
    test('guarda registro correctamente', () async {
      when(mockService.saveRegistroEspecie(
        informeId: anyNamed('informeId'),
        registro: anyNamed('registro'),
      )).thenAnswer((_) async => {});

      final registro = RegistroEspecie(
        registroId: 'reg_001',
        especieVegetal: 'Piña',
        variedad: 'Perolera',
        numeroPlantas: 3575000,
        fenologia: 'Fructificación',
        estadoFitosanitario: 'Bueno',
      );

      await repository.guardarRegistroEspecie(
        informeId: 'inf_001',
        registro: registro,
      );

      verify(mockService.saveRegistroEspecie(
        informeId: 'inf_001',
        registro: anyNamed('registro'),
      )).called(1);
    });

    test('obtiene registros de especie correctamente', () async {
      final registros = [
        RegistroEspecie(
          registroId: 'reg_001',
          especieVegetal: 'Piña',
          variedad: 'Perolera',
        ),
      ];

      when(mockService.getRegistrosEspecie(any))
          .thenAnswer((_) async => registros);

      final resultado =
          await repository.getRegistrosEspecie('inf_001');

      expect(resultado.length, 1);
      expect(resultado.first.especieVegetal, 'Piña');
    });
  });

  // ==========================================
  // EMISIÓN DEL INFORME
  // ==========================================
  group('emitirInforme', () {
    test('cambia estado a EMITIDO correctamente', () async {
      when(mockService.updateEstadoInforme(
        informeId: anyNamed('informeId'),
        estadoInforme: anyNamed('estadoInforme'),
        fechaEmision: anyNamed('fechaEmision'),
      )).thenAnswer((_) async => {});

      await repository.emitirInforme('inf_001');

      verify(mockService.updateEstadoInforme(
        informeId: 'inf_001',
        estadoInforme: EstadoInforme.EMITIDO,
        fechaEmision: anyNamed('fechaEmision'),
      )).called(1);
    });

    test('falla si el servicio lanza excepcion', () async {
      when(mockService.updateEstadoInforme(
        informeId: anyNamed('informeId'),
        estadoInforme: anyNamed('estadoInforme'),
        fechaEmision: anyNamed('fechaEmision'),
      )).thenThrow(Exception('Error de red'));

      expect(
        () => repository.emitirInforme('inf_001'),
        throwsException,
      );
    });
  });

  // ==========================================
  // GET URL PDF
  // ==========================================
  group('getUrlPdf', () {
    test('retorna URL cuando el PDF ya fue generado', () async {
      const urlEsperada =
          'https://agrotrack-a435e.web.app/?id=inf_001';

      final informeExportado = informeTest.copyWith(
        estadoInforme: EstadoInforme.EXPORTADO,
        urlPdf: urlEsperada,
      );

      when(mockService.getInformeById(any))
          .thenAnswer((_) async => informeExportado);

      final url = await repository.getUrlPdf('inf_001');

      expect(url, urlEsperada);
    });

    test('retorna null cuando el PDF aún no fue generado', () async {
      when(mockService.getInformeById(any))
          .thenAnswer((_) async => informeTest);

      final url = await repository.getUrlPdf('inf_001');

      expect(url, isNull);
    });

    test('retorna null si el informe no existe', () async {
      when(mockService.getInformeById(any))
          .thenAnswer((_) async => null);

      final url = await repository.getUrlPdf('inf_999');

      expect(url, isNull);
    });
  });
}