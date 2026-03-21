import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/productor.dart';

class ProductorService {
  final FirebaseFirestore _firestore;

  ProductorService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> createProductor(Productor productor) async {
    await _firestore.collection('usuarios').doc(productor.uidAuth).set({
      ...productor.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}