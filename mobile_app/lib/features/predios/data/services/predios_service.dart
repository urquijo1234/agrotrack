import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/predio.dart';

class PrediosService {
  final FirebaseFirestore _firestore;

  PrediosService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Predio>> getPrediosByProductor(String productorId) async {
    final snapshot = await _firestore
        .collection('predios')
        .where('productorId', isEqualTo: productorId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => Predio.fromMap(doc.data())).toList();
  }

  Future<void> createPredio(Predio predio) async {
    final docRef = _firestore.collection('predios').doc();

    await docRef.set({
      'predioId': docRef.id,
      'productorId': predio.productorId,
      'nombrePredio': predio.nombrePredio,
      'departamento': predio.departamento,
      'municipio': predio.municipio,
      'vereda': predio.vereda,
      'numeroRegistroICA': predio.numeroRegistroICA,
      'areaRegistradaHa': predio.areaRegistradaHa,
      'estadoPredio': predio.estadoPredio,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Predio?> getPredioById(String predioId) async {
    final doc = await _firestore.collection('predios').doc(predioId).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return Predio.fromMap(doc.data()!);
  }

  Future<void> updatePredio(Predio predio) async {
    await _firestore.collection('predios').doc(predio.predioId).update({
      'nombrePredio': predio.nombrePredio,
      'departamento': predio.departamento,
      'municipio': predio.municipio,
      'vereda': predio.vereda,
      'numeroRegistroICA': predio.numeroRegistroICA,
      'areaRegistradaHa': predio.areaRegistradaHa,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateEstadoPredio({
  required String predioId,
  required String estadoPredio,
}) async {
  await _firestore.collection('predios').doc(predioId).update({
    'estadoPredio': estadoPredio,
    'updatedAt': FieldValue.serverTimestamp(),
  });
}
}