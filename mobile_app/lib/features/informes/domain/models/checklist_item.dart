class ChecklistItem {
  final int numeroItem;
  final String seccion;
  final String enunciado;
  final bool tieneCumple;
  final bool tieneEstado;
  final bool tieneSenalizado;
  final bool tieneObservacion;

  ChecklistItem({
    required this.numeroItem,
    required this.seccion,
    required this.enunciado,
    required this.tieneCumple,
    required this.tieneEstado,
    required this.tieneSenalizado,
    required this.tieneObservacion,
  });

  factory ChecklistItem.fromMap(Map<String, dynamic> map) {
    return ChecklistItem(
      numeroItem: map['numeroItem'] ?? 0,
      seccion: map['seccion'] ?? '',
      enunciado: map['enunciado'] ?? '',
      tieneCumple: map['tieneCumple'] ?? false,
      tieneEstado: map['tieneEstado'] ?? false,
      tieneSenalizado: map['tieneSenalizado'] ?? false,
      tieneObservacion: map['tieneObservacion'] ?? false,
    );
  }
}