import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/informe_sanitario.dart';
import '../../domain/models/checklist_item.dart';
import '../../domain/models/checklist_respuesta.dart';
import '../../domain/models/registro_especie.dart';

class InformesService {
  final FirebaseFirestore _firestore;
  final Uuid _uuid = const Uuid();

  InformesService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ==========================================
  // CATÁLOGO DE PREGUNTAS
  // ==========================================

  Future<List<ChecklistItem>> getChecklistCatalogo() async {
    final snapshot = await _firestore
        .collection('checklistCatalogo')
        .orderBy('numeroItem')
        .get();

    return snapshot.docs
        .map((doc) => ChecklistItem.fromMap(doc.data()))
        .toList();
  }

  // ==========================================
  // INFORMES
  // ==========================================

  Future<String> createInforme(InformeFitosanitario informe) async {
    final docRef = _firestore.collection('informesFitosanitarios').doc();
    final id = docRef.id;

    await docRef.set({
      ...informe.toMap(),
      'informeId': id,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return id;
  }

  Future<List<InformeFitosanitario>> getInformesByLote(
    String loteId,
    String productorId,
  ) async {
    final snapshot = await _firestore
        .collection('informesFitosanitarios')
        .where('loteId', isEqualTo: loteId)
        .where('productorId', isEqualTo: productorId)
        .get();

    return snapshot.docs
        .map((doc) => InformeFitosanitario.fromMap(doc.data()))
        .toList()
      ..sort((a, b) => b.anioReporte.compareTo(a.anioReporte));
  }

  Future<InformeFitosanitario?> getInformeById(String informeId) async {
    final doc = await _firestore
        .collection('informesFitosanitarios')
        .doc(informeId)
        .get();

    if (!doc.exists || doc.data() == null) return null;
    return InformeFitosanitario.fromMap(doc.data()!);
  }

  Future<bool> existeInformeParaPeriodo({
  required String loteId,
  required String periodoReportado,
  required int anioReporte,
  required String productorId,
}) async {
  final snapshot = await _firestore
      .collection('informesFitosanitarios')
      .where('productorId', isEqualTo: productorId)
      .where('loteId', isEqualTo: loteId)
      .where('periodoReportado', isEqualTo: periodoReportado)
      .where('anioReporte', isEqualTo: anioReporte)
      .limit(1)
      .get();

  return snapshot.docs.isNotEmpty;
}

  Future<void> updateEstadoInforme({
    required String informeId,
    required EstadoInforme estadoInforme,
    DateTime? fechaEmision,
  }) async {
    final Map<String, dynamic> data = {
      'estadoInforme': estadoInforme.name,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (fechaEmision != null) {
      data['fechaEmision'] = fechaEmision.toIso8601String();
    }

    await _firestore
        .collection('informesFitosanitarios')
        .doc(informeId)
        .update(data);
  }

  // ==========================================
  // REGISTROS DE ESPECIE
  // ==========================================

  Future<void> saveRegistroEspecie({
    required String informeId,
    required RegistroEspecie registro,
  }) async {
    final id = registro.registroId.isEmpty ? _uuid.v4() : registro.registroId;
    await _firestore
        .collection('informesFitosanitarios')
        .doc(informeId)
        .collection('registrosEspecie')
        .doc(id)
        .set(registro.toMap()..['registroId'] = id);
  }

  Future<List<RegistroEspecie>> getRegistrosEspecie(String informeId) async {
    final snapshot = await _firestore
        .collection('informesFitosanitarios')
        .doc(informeId)
        .collection('registrosEspecie')
        .get();

    return snapshot.docs
        .map((doc) => RegistroEspecie.fromMap(doc.data()))
        .toList();
  }

  Future<void> deleteRegistroEspecie({
    required String informeId,
    required String registroId,
  }) async {
    await _firestore
        .collection('informesFitosanitarios')
        .doc(informeId)
        .collection('registrosEspecie')
        .doc(registroId)
        .delete();
  }

  // ==========================================
  // CHECKLIST RESPUESTAS
  // ==========================================

  Future<void> saveChecklistRespuestas({
    required String informeId,
    required List<ChecklistRespuesta> respuestas,
  }) async {
    final batch = _firestore.batch();

    for (final respuesta in respuestas) {
      final docRef = _firestore
          .collection('informesFitosanitarios')
          .doc(informeId)
          .collection('checklistRespuestas')
          .doc(respuesta.numeroItem.toString());

      batch.set(docRef, respuesta.toMap());
    }

    await batch.commit();
  }

  Future<List<ChecklistRespuesta>> getChecklistRespuestas(
      String informeId) async {
    final snapshot = await _firestore
        .collection('informesFitosanitarios')
        .doc(informeId)
        .collection('checklistRespuestas')
        .orderBy('numeroItem')
        .get();

    return snapshot.docs
        .map((doc) => ChecklistRespuesta.fromMap(doc.data()))
        .toList();
  }
}