import 'package:cloud_firestore/cloud_firestore.dart';

class Lote {
  final String loteId;
  final String predioId;
  final String productorId;

  final String nombreLote;
  final String? codigoLote;
  final double areaHectareas;

  final String especieVegetalActual;
  final String? variedadActual;
  final String estadoLote;
  final String? observaciones;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  Lote({
    required this.loteId,
    required this.predioId,
    required this.productorId,
    required this.nombreLote,
    this.codigoLote,
    required this.areaHectareas,
    required this.especieVegetalActual,
    this.variedadActual,
    required this.estadoLote,
    this.observaciones,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'loteId': loteId,
      'predioId': predioId,
      'productorId': productorId,
      'nombreLote': nombreLote,
      'codigoLote': codigoLote,
      'areaHectareas': areaHectareas,
      'especieVegetalActual': especieVegetalActual,
      'variedadActual': variedadActual,
      'estadoLote': estadoLote,
      'observaciones': observaciones,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory Lote.fromMap(Map<String, dynamic> map) {
    return Lote(
      loteId: map['loteId'] ?? '',
      predioId: map['predioId'] ?? '',
      productorId: map['productorId'] ?? '',
      nombreLote: map['nombreLote'] ?? '',
      codigoLote: map['codigoLote'],
      areaHectareas: (map['areaHectareas'] as num?)?.toDouble() ?? 0,
      especieVegetalActual: map['especieVegetalActual'] ?? '',
      variedadActual: map['variedadActual'],
      estadoLote: map['estadoLote'] ?? 'ACTIVO',
      observaciones: map['observaciones'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}