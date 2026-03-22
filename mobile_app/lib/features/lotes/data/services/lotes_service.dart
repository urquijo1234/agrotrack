import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/lote.dart';

class LotesService {
  final FirebaseFirestore _firestore;

  LotesService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> createLote(Lote lote) async {
    final docRef = _firestore.collection('lotes').doc();

    await docRef.set({
      'loteId': docRef.id,
      'predioId': lote.predioId,
      'productorId': lote.productorId,
      'nombreLote': lote.nombreLote,
      'codigoLote': lote.codigoLote,
      'areaHectareas': lote.areaHectareas,
      'especieVegetalActual': lote.especieVegetalActual,
      'variedadActual': lote.variedadActual,
      'estadoLote': lote.estadoLote,
      'observaciones': lote.observaciones,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Lote>> getLotesByPredio({
    required String predioId,
    required String productorId,
  }) async {
    final snapshot = await _firestore
        .collection('lotes')
        .where('predioId', isEqualTo: predioId)
        .where('productorId', isEqualTo: productorId)
        .get();

    return snapshot.docs.map((doc) => Lote.fromMap(doc.data())).toList();
  }

  Future<Lote?> getLoteById(String loteId) async {
    final doc = await _firestore.collection('lotes').doc(loteId).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return Lote.fromMap(doc.data()!);
  }

  Future<void> updateLote(Lote lote) async {
    await _firestore.collection('lotes').doc(lote.loteId).update({
      'nombreLote': lote.nombreLote,
      'codigoLote': lote.codigoLote,
      'areaHectareas': lote.areaHectareas,
      'especieVegetalActual': lote.especieVegetalActual,
      'variedadActual': lote.variedadActual,
      'observaciones': lote.observaciones,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateEstadoLote({
  required String loteId,
  required String estadoLote,
}) async {
  await _firestore.collection('lotes').doc(loteId).update({
    'estadoLote': estadoLote,
    'updatedAt': FieldValue.serverTimestamp(),
  });
}
}