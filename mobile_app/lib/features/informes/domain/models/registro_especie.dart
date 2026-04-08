class RegistroEspecie {
  final String registroId;
  final String especieVegetal;
  final int? numeroLotesOTotes;
  final String? variedad;
  final DateTime? fechaSiembra;
  final int? numeroPlantas;
  final String? fenologia;
  final String? estadoFitosanitario;
  final double? produccionEstimada;
  final String? unidadProduccion;
  final String? frecuenciaMonitoreo;
  final double? porcentajeArea;

  RegistroEspecie({
    required this.registroId,
    required this.especieVegetal,
    this.numeroLotesOTotes,
    this.variedad,
    this.fechaSiembra,
    this.numeroPlantas,
    this.fenologia,
    this.estadoFitosanitario,
    this.produccionEstimada,
    this.unidadProduccion,
    this.frecuenciaMonitoreo,
    this.porcentajeArea,
  });

  Map<String, dynamic> toMap() {
    return {
      'registroId': registroId,
      'especieVegetal': especieVegetal,
      'numeroLotesOTotes': numeroLotesOTotes,
      'variedad': variedad,
      'fechaSiembra': fechaSiembra?.toIso8601String(),
      'numeroPlantas': numeroPlantas,
      'fenologia': fenologia,
      'estadoFitosanitario': estadoFitosanitario,
      'produccionEstimada': produccionEstimada,
      'unidadProduccion': unidadProduccion,
      'frecuenciaMonitoreo': frecuenciaMonitoreo,
      'porcentajeArea': porcentajeArea,
    };
  }

  factory RegistroEspecie.fromMap(Map<String, dynamic> map) {
    return RegistroEspecie(
      registroId: map['registroId'] ?? '',
      especieVegetal: map['especieVegetal'] ?? '',
      numeroLotesOTotes: map['numeroLotesOTotes'],
      variedad: map['variedad'],
      fechaSiembra: map['fechaSiembra'] != null
          ? DateTime.tryParse(map['fechaSiembra'])
          : null,
      numeroPlantas: map['numeroPlantas'],
      fenologia: map['fenologia'],
      estadoFitosanitario: map['estadoFitosanitario'],
      produccionEstimada: (map['produccionEstimada'] as num?)?.toDouble(),
      unidadProduccion: map['unidadProduccion'],
      frecuenciaMonitoreo: map['frecuenciaMonitoreo'],
      porcentajeArea: (map['porcentajeArea'] as num?)?.toDouble(),
    );
  }
}