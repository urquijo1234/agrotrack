import 'package:cloud_firestore/cloud_firestore.dart';

class Predio {
  final String predioId;
  final String productorId;

  final String nombrePredio;
  final String departamento;
  final String municipio;

  final String? vereda;
  final String? numeroRegistroICA;
  final double? areaRegistradaHa;

  final String estadoPredio;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  Predio({
    required this.predioId,
    required this.productorId,
    required this.nombrePredio,
    required this.departamento,
    required this.municipio,
    this.vereda,
    this.numeroRegistroICA,
    this.areaRegistradaHa,
    required this.estadoPredio,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'predioId': predioId,
      'productorId': productorId,
      'nombrePredio': nombrePredio,
      'departamento': departamento,
      'municipio': municipio,
      'vereda': vereda,
      'numeroRegistroICA': numeroRegistroICA,
      'areaRegistradaHa': areaRegistradaHa,
      'estadoPredio': estadoPredio,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory Predio.fromMap(Map<String, dynamic> map) {
    return Predio(
      predioId: map['predioId'] ?? '',
      productorId: map['productorId'] ?? '',
      nombrePredio: map['nombrePredio'] ?? '',
      departamento: map['departamento'] ?? '',
      municipio: map['municipio'] ?? '',
      vereda: map['vereda'],
      numeroRegistroICA: map['numeroRegistroICA'],
      areaRegistradaHa: map['areaRegistradaHa'] != null
          ? (map['areaRegistradaHa'] as num).toDouble()
          : null,
      estadoPredio: map['estadoPredio'] ?? 'ACTIVO',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}