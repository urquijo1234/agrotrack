import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

enum TipoEvento { SIEMBRA, APLICACION_INSUMO, COSECHA }

class EventoAgricola {
  final String eventoId;
  final String loteId;
  final String predioId;
  final String productorId;
  final TipoEvento tipoEvento;
  final DateTime fechaEvento;
  final String? descripcion;
  final Map<String, dynamic> detalleEvento; // Payload flexible según tipo
  
  // Campos de control local (Nota 7.10 del diseño)
  final bool isSynced;
  
  final DateTime? createdAt;
  final DateTime? updatedAt;

  EventoAgricola({
    required this.eventoId,
    required this.loteId,
    required this.predioId,
    required this.productorId,
    required this.tipoEvento,
    required this.fechaEvento,
    this.descripcion,
    required this.detalleEvento,
    this.isSynced = false,
    this.createdAt,
    this.updatedAt,
  });

  // ==========================================
  // SERIALIZACIÓN PARA FIRESTORE (NUBE)
  // ==========================================
  
  Map<String, dynamic> toMap() {
    return {
      'eventoId': eventoId,
      'loteId': loteId,
      'predioId': predioId,
      'productorId': productorId,
      'tipoEvento': tipoEvento.name,
      'fechaEvento': Timestamp.fromDate(fechaEvento),
      'descripcion': descripcion,
      'detalleEvento': detalleEvento,
      'isSynced': true, // Si va a Firestore, por definición ya está sincronizado
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory EventoAgricola.fromMap(Map<String, dynamic> map) {
    return EventoAgricola(
      eventoId: map['eventoId'] ?? '',
      loteId: map['loteId'] ?? '',
      predioId: map['predioId'] ?? '',
      productorId: map['productorId'] ?? '',
      tipoEvento: TipoEvento.values.firstWhere(
        (e) => e.name == map['tipoEvento'],
        orElse: () => TipoEvento.APLICACION_INSUMO,
      ),
      fechaEvento: (map['fechaEvento'] as Timestamp).toDate(),
      descripcion: map['descripcion'],
      detalleEvento: Map<String, dynamic>.from(map['detalleEvento'] ?? {}),
      isSynced: true, // Lo que viene de Firestore está sincronizado
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  // ==========================================
  // SERIALIZACIÓN PARA SQLITE (LOCAL)
  // ==========================================
  
  Map<String, dynamic> toSqliteMap() {
    return {
      'eventoId': eventoId,
      'loteId': loteId,
      'predioId': predioId,
      'productorId': productorId,
      'tipoEvento': tipoEvento.name,
      'fechaEvento': fechaEvento.toIso8601String(),
      'descripcion': descripcion,
      'detalleEvento': jsonEncode(detalleEvento), // Convertimos el Map a JSON String
      'isSynced': isSynced ? 1 : 0, // SQLite no tiene booleanos, usa 1 y 0
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  factory EventoAgricola.fromSqliteMap(Map<String, dynamic> map) {
    return EventoAgricola(
      eventoId: map['eventoId'] ?? '',
      loteId: map['loteId'] ?? '',
      predioId: map['predioId'] ?? '',
      productorId: map['productorId'] ?? '',
      tipoEvento: TipoEvento.values.firstWhere(
        (e) => e.name == map['tipoEvento'],
        orElse: () => TipoEvento.APLICACION_INSUMO,
      ),
      fechaEvento: DateTime.parse(map['fechaEvento']),
      descripcion: map['descripcion'],
      detalleEvento: jsonDecode(map['detalleEvento'] ?? '{}'), // Convertimos el JSON String a Map
      isSynced: map['isSynced'] == 1,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  // Método de copia para inmutabilidad (muy útil al actualizar estado de sincronización)
  EventoAgricola copyWith({
    bool? isSynced,
    DateTime? updatedAt,
  }) {
    return EventoAgricola(
      eventoId: eventoId,
      loteId: loteId,
      predioId: predioId,
      productorId: productorId,
      tipoEvento: tipoEvento,
      fechaEvento: fechaEvento,
      descripcion: descripcion,
      detalleEvento: detalleEvento,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}