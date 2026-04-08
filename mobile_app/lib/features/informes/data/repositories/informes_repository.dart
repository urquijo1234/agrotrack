import '../../domain/models/informe_sanitario.dart';
import '../../domain/models/checklist_item.dart';
import '../../domain/models/checklist_respuesta.dart';
import '../../domain/models/registro_especie.dart';
import '../services/informes_service.dart';
import '../../../lotes/domain/models/lote.dart';
import '../../../predios/domain/models/predio.dart';
import '../../../auth/domain/models/productor.dart';

class InformesRepository {
  final InformesService _service;

  InformesRepository({InformesService? service})
      : _service = service ?? InformesService();

  // ==========================================
  // CATÁLOGO
  // ==========================================

  Future<List<ChecklistItem>> getChecklistCatalogo() {
    return _service.getChecklistCatalogo();
  }

  // ==========================================
  // INFORMES
  // ==========================================

  /// Crea un informe nuevo en BORRADOR con snapshot del predio/lote/productor
  Future<String> crearInforme({
    required Lote lote,
    required Predio predio,
    required Productor productor,
    required PeriodoReportado periodo,
    required int anio,
  }) async {
    // Verificar que no exista un informe para ese periodo y lote
    final existe = await _service.existeInformeParaPeriodo(
  loteId: lote.loteId,
  periodoReportado: periodo.name,
  anioReporte: anio,
  productorId: productor.productorId,
);

    if (existe) {
      throw Exception(
        'Ya existe un informe para este lote en el periodo seleccionado.',
      );
    }

    final informe = InformeFitosanitario(
      informeId: '',
      loteId: lote.loteId,
      predioId: predio.predioId,
      productorId: productor.productorId,
      periodoReportado: periodo,
      anioReporte: anio,
      estadoInforme: EstadoInforme.BORRADOR,
      // Snapshot — captura el estado actual
      nombrePredioReportado: predio.nombrePredio,
      nombreTitularReportado: productor.nombreCompleto,
      departamentoReportado: predio.departamento,
      municipioReportado: predio.municipio,
      numeroRegistroICA: predio.numeroRegistroICA,
      especieVegetalReportada: lote.especieVegetalActual,
    );

    return _service.createInforme(informe);
  }

  Future<List<InformeFitosanitario>> getInformesByLote(
    String loteId,
    String productorId,
  ) {
    return _service.getInformesByLote(loteId, productorId);
  }

  Future<InformeFitosanitario?> getInformeById(String informeId) {
    return _service.getInformeById(informeId);
  }

  // ==========================================
  // REGISTROS DE ESPECIE
  // ==========================================

  Future<void> guardarRegistroEspecie({
    required String informeId,
    required RegistroEspecie registro,
  }) {
    return _service.saveRegistroEspecie(
      informeId: informeId,
      registro: registro,
    );
  }

  Future<List<RegistroEspecie>> getRegistrosEspecie(String informeId) {
    return _service.getRegistrosEspecie(informeId);
  }

  Future<void> eliminarRegistroEspecie({
    required String informeId,
    required String registroId,
  }) {
    return _service.deleteRegistroEspecie(
      informeId: informeId,
      registroId: registroId,
    );
  }

  // ==========================================
  // CHECKLIST
  // ==========================================

  Future<void> guardarChecklistRespuestas({
    required String informeId,
    required List<ChecklistRespuesta> respuestas,
  }) {
    return _service.saveChecklistRespuestas(
      informeId: informeId,
      respuestas: respuestas,
    );
  }

  Future<List<ChecklistRespuesta>> getChecklistRespuestas(String informeId) {
    return _service.getChecklistRespuestas(informeId);
  }

  // ==========================================
  // EMISIÓN DEL INFORME
  // ==========================================

  /// Cambia el estado a EMITIDO — esto dispara la Cloud Function
  Future<void> emitirInforme(String informeId) {
    return _service.updateEstadoInforme(
      informeId: informeId,
      estadoInforme: EstadoInforme.EMITIDO,
      fechaEmision: DateTime.now(),
    );
  }

  /// Refresca el informe para obtener la urlPdf cuando ya fue generada
  Future<String?> getUrlPdf(String informeId) async {
    final informe = await _service.getInformeById(informeId);
    return informe?.urlPdf;
  }
}