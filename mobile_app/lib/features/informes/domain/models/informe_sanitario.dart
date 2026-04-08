enum PeriodoReportado {
  FEB_MAR_ABR,
  MAY_JUN_JUL,
  AGO_SEP_OCT,
  NOV_DIC_ENE,
}

enum EstadoInforme {
  BORRADOR,
  EMITIDO,
  EXPORTADO,
}

class InformeFitosanitario {
  final String informeId;
  final String loteId;
  final String predioId;
  final String productorId;
  final PeriodoReportado periodoReportado;
  final int anioReporte;
  final EstadoInforme estadoInforme;
  final DateTime? fechaEmision;
  final String? urlPdf;

  // Snapshot del estado del predio al momento del informe
  final String nombrePredioReportado;
  final String nombreTitularReportado;
  final String departamentoReportado;
  final String municipioReportado;
  final String? numeroRegistroICA;
  final String especieVegetalReportada;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  InformeFitosanitario({
    required this.informeId,
    required this.loteId,
    required this.predioId,
    required this.productorId,
    required this.periodoReportado,
    required this.anioReporte,
    required this.estadoInforme,
    this.fechaEmision,
    this.urlPdf,
    required this.nombrePredioReportado,
    required this.nombreTitularReportado,
    required this.departamentoReportado,
    required this.municipioReportado,
    this.numeroRegistroICA,
    required this.especieVegetalReportada,
    this.createdAt,
    this.updatedAt,
  });

  // Etiqueta legible del periodo
  String get periodoLabel {
    switch (periodoReportado) {
      case PeriodoReportado.FEB_MAR_ABR:
        return 'Febrero - Marzo - Abril';
      case PeriodoReportado.MAY_JUN_JUL:
        return 'Mayo - Junio - Julio';
      case PeriodoReportado.AGO_SEP_OCT:
        return 'Agosto - Septiembre - Octubre';
      case PeriodoReportado.NOV_DIC_ENE:
        return 'Noviembre - Diciembre - Enero';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'informeId': informeId,
      'loteId': loteId,
      'predioId': predioId,
      'productorId': productorId,
      'periodoReportado': periodoReportado.name,
      'anioReporte': anioReporte,
      'estadoInforme': estadoInforme.name,
      'fechaEmision': fechaEmision?.toIso8601String(),
      'urlPdf': urlPdf,
      'nombrePredioReportado': nombrePredioReportado,
      'nombreTitularReportado': nombreTitularReportado,
      'departamentoReportado': departamentoReportado,
      'municipioReportado': municipioReportado,
      'numeroRegistroICA': numeroRegistroICA,
      'especieVegetalReportada': especieVegetalReportada,
    };
  }

  factory InformeFitosanitario.fromMap(Map<String, dynamic> map) {
    return InformeFitosanitario(
      informeId: map['informeId'] ?? '',
      loteId: map['loteId'] ?? '',
      predioId: map['predioId'] ?? '',
      productorId: map['productorId'] ?? '',
      periodoReportado: PeriodoReportado.values.firstWhere(
        (e) => e.name == map['periodoReportado'],
        orElse: () => PeriodoReportado.FEB_MAR_ABR,
      ),
      anioReporte: map['anioReporte'] ?? DateTime.now().year,
      estadoInforme: EstadoInforme.values.firstWhere(
        (e) => e.name == map['estadoInforme'],
        orElse: () => EstadoInforme.BORRADOR,
      ),
      fechaEmision: map['fechaEmision'] != null
          ? DateTime.tryParse(map['fechaEmision'])
          : null,
      urlPdf: map['urlPdf'],
      nombrePredioReportado: map['nombrePredioReportado'] ?? '',
      nombreTitularReportado: map['nombreTitularReportado'] ?? '',
      departamentoReportado: map['departamentoReportado'] ?? '',
      municipioReportado: map['municipioReportado'] ?? '',
      numeroRegistroICA: map['numeroRegistroICA'],
      especieVegetalReportada: map['especieVegetalReportada'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString())
          : null,
    );
  }

  InformeFitosanitario copyWith({
    EstadoInforme? estadoInforme,
    DateTime? fechaEmision,
    String? urlPdf,
  }) {
    return InformeFitosanitario(
      informeId: informeId,
      loteId: loteId,
      predioId: predioId,
      productorId: productorId,
      periodoReportado: periodoReportado,
      anioReporte: anioReporte,
      estadoInforme: estadoInforme ?? this.estadoInforme,
      fechaEmision: fechaEmision ?? this.fechaEmision,
      urlPdf: urlPdf ?? this.urlPdf,
      nombrePredioReportado: nombrePredioReportado,
      nombreTitularReportado: nombreTitularReportado,
      departamentoReportado: departamentoReportado,
      municipioReportado: municipioReportado,
      numeroRegistroICA: numeroRegistroICA,
      especieVegetalReportada: especieVegetalReportada,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}