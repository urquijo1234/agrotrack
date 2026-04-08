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
import 'informe_flow_test.mocks.dart';

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

  setUp(() {
    mockService = MockInformesService();
    repository = InformesRepository(service: mockService);
  });

  // ==========================================
  // FLUJO COMPLETO: CREAR → LLENAR → EMITIR
  // ==========================================
  group('Flujo completo del informe', () {
    test('flujo crear → registrar especie → llenar checklist → emitir',
        () async {
      // PASO 1 — Crear informe
      when(mockService.existeInformeParaPeriodo(
        loteId: anyNamed('loteId'),
        periodoReportado: anyNamed('periodoReportado'),
        anioReporte: anyNamed('anioReporte'),
        productorId: anyNamed('productorId'),
      )).thenAnswer((_) async => false);

      when(mockService.createInforme(any))
          .thenAnswer((_) async => 'inf_001');

      final informeId = await repository.crearInforme(
        lote: loteTest,
        predio: predioTest,
        productor: productorTest,
        periodo: PeriodoReportado.FEB_MAR_ABR,
        anio: 2026,
      );

      expect(informeId, 'inf_001');

      // PASO 2 — Registrar especie
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
        produccionEstimada: 200000,
        unidadProduccion: 'piñas/mes',
        frecuenciaMonitoreo: 'Mensual',
        porcentajeArea: 30.0,
      );

      await repository.guardarRegistroEspecie(
        informeId: informeId,
        registro: registro,
      );

      verify(mockService.saveRegistroEspecie(
        informeId: informeId,
        registro: anyNamed('registro'),
      )).called(1);

      // PASO 3 — Llenar checklist
      when(mockService.saveChecklistRespuestas(
        informeId: anyNamed('informeId'),
        respuestas: anyNamed('respuestas'),
      )).thenAnswer((_) async => {});

      final respuestas = [
        ChecklistRespuesta(
            numeroItem: 35,
            seccion: 'V',
            cumple: true,
            estado: 'B',
            senalizado: true),
        ChecklistRespuesta(
            numeroItem: 44, seccion: 'VI', cumple: true),
        ChecklistRespuesta(
            numeroItem: 57, seccion: 'VII', cumple: true),
        ChecklistRespuesta(
            numeroItem: 92,
            seccion: 'INFO',
            observacion: 'Plan PCO vigente'),
      ];

      await repository.guardarChecklistRespuestas(
        informeId: informeId,
        respuestas: respuestas,
      );

      verify(mockService.saveChecklistRespuestas(
        informeId: informeId,
        respuestas: anyNamed('respuestas'),
      )).called(1);

      // PASO 4 — Emitir informe
      when(mockService.updateEstadoInforme(
        informeId: anyNamed('informeId'),
        estadoInforme: anyNamed('estadoInforme'),
        fechaEmision: anyNamed('fechaEmision'),
      )).thenAnswer((_) async => {});

      await repository.emitirInforme(informeId);

      verify(mockService.updateEstadoInforme(
        informeId: informeId,
        estadoInforme: EstadoInforme.EMITIDO,
        fechaEmision: anyNamed('fechaEmision'),
      )).called(1);
    });

    test('no se puede crear dos informes del mismo lote y periodo',
        () async {
      // Primer intento — no existe
      when(mockService.existeInformeParaPeriodo(
        loteId: anyNamed('loteId'),
        periodoReportado: anyNamed('periodoReportado'),
        anioReporte: anyNamed('anioReporte'),
        productorId: anyNamed('productorId'),
      )).thenAnswer((_) async => false);

      when(mockService.createInforme(any))
          .thenAnswer((_) async => 'inf_001');

      await repository.crearInforme(
        lote: loteTest,
        predio: predioTest,
        productor: productorTest,
        periodo: PeriodoReportado.FEB_MAR_ABR,
        anio: 2026,
      );

      // Segundo intento — ya existe
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
    });

    test('flujo QR — polling hasta obtener URL del PDF', () async {
      // Primera llamada — sin PDF todavía
      when(mockService.getInformeById(any)).thenAnswer((_) async =>
          InformeFitosanitario(
            informeId: 'inf_001',
            loteId: 'lot_001',
            predioId: 'pred_001',
            productorId: 'uid_123',
            periodoReportado: PeriodoReportado.FEB_MAR_ABR,
            anioReporte: 2026,
            estadoInforme: EstadoInforme.EMITIDO,
            urlPdf: null,
            nombrePredioReportado: 'Finca El Porvenir',
            nombreTitularReportado: 'Luis Alberto Gómez',
            departamentoReportado: 'Santander',
            municipioReportado: 'Lebrija',
            especieVegetalReportada: 'Piña',
          ));

      final urlAntes = await repository.getUrlPdf('inf_001');
      expect(urlAntes, isNull);

      // Segunda llamada — PDF ya generado
      when(mockService.getInformeById(any)).thenAnswer((_) async =>
          InformeFitosanitario(
            informeId: 'inf_001',
            loteId: 'lot_001',
            predioId: 'pred_001',
            productorId: 'uid_123',
            periodoReportado: PeriodoReportado.FEB_MAR_ABR,
            anioReporte: 2026,
            estadoInforme: EstadoInforme.EXPORTADO,
            urlPdf: 'https://agrotrack-a435e.web.app/?id=inf_001',
            nombrePredioReportado: 'Finca El Porvenir',
            nombreTitularReportado: 'Luis Alberto Gómez',
            departamentoReportado: 'Santander',
            municipioReportado: 'Lebrija',
            especieVegetalReportada: 'Piña',
          ));

      final urlDespues = await repository.getUrlPdf('inf_001');
      expect(urlDespues, 'https://agrotrack-a435e.web.app/?id=inf_001');
    });

    test('informes de distintos periodos del mismo lote son independientes',
        () async {
      when(mockService.existeInformeParaPeriodo(
        loteId: anyNamed('loteId'),
        periodoReportado: anyNamed('periodoReportado'),
        anioReporte: anyNamed('anioReporte'),
        productorId: anyNamed('productorId'),
      )).thenAnswer((_) async => false);

      when(mockService.createInforme(any))
          .thenAnswer((_) async => 'inf_new');

      // Crear para FEB_MAR_ABR
      final id1 = await repository.crearInforme(
        lote: loteTest,
        predio: predioTest,
        productor: productorTest,
        periodo: PeriodoReportado.FEB_MAR_ABR,
        anio: 2026,
      );

      // Crear para MAY_JUN_JUL — debe funcionar porque es periodo distinto
      final id2 = await repository.crearInforme(
        lote: loteTest,
        predio: predioTest,
        productor: productorTest,
        periodo: PeriodoReportado.MAY_JUN_JUL,
        anio: 2026,
      );

      expect(id1, isNotEmpty);
      expect(id2, isNotEmpty);
      verify(mockService.createInforme(any)).called(2);
    });
  });
}