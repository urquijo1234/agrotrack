import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/evento_agricola.dart';

class EventosFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sube un evento a Firestore usando su ID local (UUID) como ID del documento
  Future<void> pushEvento(EventoAgricola evento) async {
    final docRef = _firestore.collection('eventos').doc(evento.eventoId);
    
    // Usamos set() en lugar de add() porque el UUID ya viene generado desde SQLite
    await docRef.set(evento.toMap());
  }

  /// Descarga los eventos de un lote desde Firestore
  Future<List<EventoAgricola>> getEventosFromFirebase(String loteId, String productorId) async {
    final snapshot = await _firestore
        .collection('eventos')
        .where('loteId', isEqualTo: loteId)
        .where('productorId', isEqualTo: productorId) 
        .get();

    return snapshot.docs.map((doc) {
      // 1. Convertimos el documento a nuestro objeto EventoAgricola
      final evento = EventoAgricola.fromMap(doc.data());
      
      // 2. FORZAMOS explícitamente el isSynced a true. 
      // Así, cuando el Repositorio llame a toSqliteMap(), guardará un "1" en la base local.
      return evento.copyWith(isSynced: true);
    }).toList();
  }
}