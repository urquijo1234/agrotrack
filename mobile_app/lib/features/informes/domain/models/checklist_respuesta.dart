class ChecklistRespuesta {
  final int numeroItem;
  final String seccion;
  final bool? cumple;
  final String? estado;       // "B" | "M" | null
  final bool? senalizado;
  final String? observacion;

  ChecklistRespuesta({
    required this.numeroItem,
    required this.seccion,
    this.cumple,
    this.estado,
    this.senalizado,
    this.observacion,
  });

  Map<String, dynamic> toMap() {
    return {
      'numeroItem': numeroItem,
      'seccion': seccion,
      'cumple': cumple,
      'estado': estado,
      'senalizado': senalizado,
      'observacion': observacion,
    };
  }

  factory ChecklistRespuesta.fromMap(Map<String, dynamic> map) {
    return ChecklistRespuesta(
      numeroItem: map['numeroItem'] ?? 0,
      seccion: map['seccion'] ?? '',
      cumple: map['cumple'],
      estado: map['estado'],
      senalizado: map['senalizado'],
      observacion: map['observacion'],
    );
  }

  ChecklistRespuesta copyWith({
    bool? cumple,
    String? estado,
    bool? senalizado,
    String? observacion,
  }) {
    return ChecklistRespuesta(
      numeroItem: numeroItem,
      seccion: seccion,
      cumple: cumple ?? this.cumple,
      estado: estado ?? this.estado,
      senalizado: senalizado ?? this.senalizado,
      observacion: observacion ?? this.observacion,
    );
  }
}