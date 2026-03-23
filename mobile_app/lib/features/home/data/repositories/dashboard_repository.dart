import 'package:cloud_firestore/cloud_firestore.dart';
// ¡Importación corregida!
import '../../../auth/domain/models/productor.dart'; 
import '../../../lotes/domain/models/lote.dart';

class DashboardRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Retornamos directamente tu objeto Productor
  Future<Productor?> getProductor(String uid) async {
    final doc = await _firestore.collection('usuarios').doc(uid).get();
    if (doc.exists) {
      // Nota: Si tu Productor no tiene un factory fromMap, 
      // puedes usar doc.data() y mapearlo a mano aquí, o crearle el factory.
      final data = doc.data()!;
      return Productor(
        productorId: data['productorId'] ?? uid,
        uidAuth: data['uidAuth'] ?? uid,
        nombreCompleto: data['nombreCompleto'] ?? 'Productor',
        correo: data['correo'] ?? '',
        telefono: data['telefono'],
        estadoCuenta: data['estadoCuenta'] ?? 'ACTIVO',
      );
    }
    return null;
  }

  Future<int> countPredios(String uid) async {
    final snapshot = await _firestore.collection('predios').where('productorId', isEqualTo: uid).count().get();
    return snapshot.count ?? 0;
  }

  Future<int> countLotesActivos(String uid) async {
    final snapshot = await _firestore.collection('lotes')
        .where('productorId', isEqualTo: uid)
        .where('estadoLote', isEqualTo: 'ACTIVO')
        .count().get();
    return snapshot.count ?? 0;
  }

  Future<List<Lote>> getLotesRecientes(String uid) async {
    final snapshot = await _firestore.collection('lotes')
        .where('productorId', isEqualTo: uid)
        .limit(3)
        .get();
    return snapshot.docs.map((doc) => Lote.fromMap(doc.data())).toList();
  }

  // 5. Obtener TODOS los lotes activos para el selector de acciones rápidas
  Future<List<Lote>> getActiveLotes(String uid) async {
    final snapshot = await _firestore
        .collection('lotes')
        .where('productorId', isEqualTo: uid)
        .where('estadoLote', isEqualTo: 'ACTIVO')
        .get();

    return snapshot.docs.map((doc) => Lote.fromMap(doc.data())).toList();
  }
}