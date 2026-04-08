import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/informes/domain/models/informe_sanitario.dart';

void main() {
  group('InformeFitosanitario', () {
    final informeCompleto = InformeFitosanitario(
      informeId: 'inf_001',
      loteId: 'lot_001',
      predioId: 'pred_001',
      productorId: 'uid_123',
      periodoReportado: PeriodoReportado.FEB_MAR_ABR,
      anioReporte: 2026,
      estadoInforme: EstadoInforme.BORRADOR,
      nombrePredioReportado: 'Finca El Porvenir',
      nombreTitularReportado: 'Luis Alberto Gómez',
      departamentoReportado: 'Santander',
      municipioReportado: 'Lebrija',
      numeroRegistroICA: 'ICA-45892',
      especieVegetalReportada: 'Piña',
    );

    // ==========================================
    // TESTS toMap
    // ==========================================
    group('toMap', () {
      test('incluye todos los campos obligatorios', () {
        final map = informeCompleto.toMap();

        expect(map['informeId'], 'inf_001');
        expect(map['loteId'], 'lot_001');
        expect(map['predioId'], 'pred_001');
        expect(map['productorId'], 'uid_123');
        expect(map['periodoReportado'], 'FEB_MAR_ABR');
        expect(map['anioReporte'], 2026);
        expect(map['estadoInforme'], 'BORRADOR');
        expect(map['nombrePredioReportado'], 'Finca El Porvenir');
        expect(map['nombreTitularReportado'], 'Luis Alberto Gómez');
        expect(map['departamentoReportado'], 'Santander');
        expect(map['municipioReportado'], 'Lebrija');
        expect(map['numeroRegistroICA'], 'ICA-45892');
        expect(map['especieVegetalReportada'], 'Piña');
      });

      test('urlPdf es null cuando no ha sido generado', () {
        final map = informeCompleto.toMap();
        expect(map['urlPdf'], isNull);
      });

      test('serializa periodo correctamente como string', () {
        final map = informeCompleto.toMap();
        expect(map['periodoReportado'], isA<String>());
        expect(map['periodoReportado'], 'FEB_MAR_ABR');
      });

      test('serializa estado correctamente como string', () {
        final map = informeCompleto.toMap();
        expect(map['estadoInforme'], isA<String>());
        expect(map['estadoInforme'], 'BORRADOR');
      });
    });

    // ==========================================
    // TESTS fromMap
    // ==========================================
    group('fromMap', () {
      test('reconstruye el informe correctamente', () {
        final map = {
          'informeId': 'inf_001',
          'loteId': 'lot_001',
          'predioId': 'pred_001',
          'productorId': 'uid_123',
          'periodoReportado': 'FEB_MAR_ABR',
          'anioReporte': 2026,
          'estadoInforme': 'BORRADOR',
          'urlPdf': null,
          'fechaEmision': null,
          'nombrePredioReportado': 'Finca El Porvenir',
          'nombreTitularReportado': 'Luis Alberto Gómez',
          'departamentoReportado': 'Santander',
          'municipioReportado': 'Lebrija',
          'numeroRegistroICA': 'ICA-45892',
          'especieVegetalReportada': 'Piña',
        };

        final informe = InformeFitosanitario.fromMap(map);

        expect(informe.informeId, 'inf_001');
        expect(informe.loteId, 'lot_001');
        expect(informe.periodoReportado, PeriodoReportado.FEB_MAR_ABR);
        expect(informe.estadoInforme, EstadoInforme.BORRADOR);
        expect(informe.anioReporte, 2026);
        expect(informe.urlPdf, isNull);
      });

      test('reconstruye todos los periodos correctamente', () {
        for (final periodo in PeriodoReportado.values) {
          final map = {
            'informeId': 'inf_test',
            'loteId': 'lot_001',
            'predioId': 'pred_001',
            'productorId': 'uid_123',
            'periodoReportado': periodo.name,
            'anioReporte': 2026,
            'estadoInforme': 'BORRADOR',
            'nombrePredioReportado': 'Predio',
            'nombreTitularReportado': 'Titular',
            'departamentoReportado': 'Santander',
            'municipioReportado': 'Lebrija',
            'especieVegetalReportada': 'Piña',
          };

          final informe = InformeFitosanitario.fromMap(map);
          expect(informe.periodoReportado, periodo);
        }
      });

      test('reconstruye todos los estados correctamente', () {
        for (final estado in EstadoInforme.values) {
          final map = {
            'informeId': 'inf_test',
            'loteId': 'lot_001',
            'predioId': 'pred_001',
            'productorId': 'uid_123',
            'periodoReportado': 'FEB_MAR_ABR',
            'anioReporte': 2026,
            'estadoInforme': estado.name,
            'nombrePredioReportado': 'Predio',
            'nombreTitularReportado': 'Titular',
            'departamentoReportado': 'Santander',
            'municipioReportado': 'Lebrija',
            'especieVegetalReportada': 'Piña',
          };

          final informe = InformeFitosanitario.fromMap(map);
          expect(informe.estadoInforme, estado);
        }
      });

      test('usa BORRADOR como estado por defecto si valor desconocido', () {
        final map = {
          'informeId': 'inf_001',
          'loteId': 'lot_001',
          'predioId': 'pred_001',
          'productorId': 'uid_123',
          'periodoReportado': 'FEB_MAR_ABR',
          'anioReporte': 2026,
          'estadoInforme': 'ESTADO_DESCONOCIDO',
          'nombrePredioReportado': 'Predio',
          'nombreTitularReportado': 'Titular',
          'departamentoReportado': 'Santander',
          'municipioReportado': 'Lebrija',
          'especieVegetalReportada': 'Piña',
        };

        final informe = InformeFitosanitario.fromMap(map);
        expect(informe.estadoInforme, EstadoInforme.BORRADOR);
      });
    });

    // ==========================================
    // TESTS periodoLabel
    // ==========================================
    group('periodoLabel', () {
      test('FEB_MAR_ABR retorna etiqueta correcta', () {
        expect(
          informeCompleto.periodoLabel,
          'Febrero - Marzo - Abril',
        );
      });

      test('MAY_JUN_JUL retorna etiqueta correcta', () {
        final informe = informeCompleto.copyWith(
          estadoInforme: EstadoInforme.BORRADOR,
        );
        final informeMay = InformeFitosanitario(
          informeId: informe.informeId,
          loteId: informe.loteId,
          predioId: informe.predioId,
          productorId: informe.productorId,
          periodoReportado: PeriodoReportado.MAY_JUN_JUL,
          anioReporte: informe.anioReporte,
          estadoInforme: informe.estadoInforme,
          nombrePredioReportado: informe.nombrePredioReportado,
          nombreTitularReportado: informe.nombreTitularReportado,
          departamentoReportado: informe.departamentoReportado,
          municipioReportado: informe.municipioReportado,
          especieVegetalReportada: informe.especieVegetalReportada,
        );
        expect(informeMay.periodoLabel, 'Mayo - Junio - Julio');
      });

      test('AGO_SEP_OCT retorna etiqueta correcta', () {
        final informeAgo = InformeFitosanitario(
          informeId: 'inf_002',
          loteId: 'lot_001',
          predioId: 'pred_001',
          productorId: 'uid_123',
          periodoReportado: PeriodoReportado.AGO_SEP_OCT,
          anioReporte: 2026,
          estadoInforme: EstadoInforme.BORRADOR,
          nombrePredioReportado: 'Predio',
          nombreTitularReportado: 'Titular',
          departamentoReportado: 'Santander',
          municipioReportado: 'Lebrija',
          especieVegetalReportada: 'Piña',
        );
        expect(informeAgo.periodoLabel, 'Agosto - Septiembre - Octubre');
      });

      test('NOV_DIC_ENE retorna etiqueta correcta', () {
        final informeNov = InformeFitosanitario(
          informeId: 'inf_003',
          loteId: 'lot_001',
          predioId: 'pred_001',
          productorId: 'uid_123',
          periodoReportado: PeriodoReportado.NOV_DIC_ENE,
          anioReporte: 2026,
          estadoInforme: EstadoInforme.BORRADOR,
          nombrePredioReportado: 'Predio',
          nombreTitularReportado: 'Titular',
          departamentoReportado: 'Santander',
          municipioReportado: 'Lebrija',
          especieVegetalReportada: 'Piña',
        );
        expect(informeNov.periodoLabel, 'Noviembre - Diciembre - Enero');
      });
    });

    // ==========================================
    // TESTS copyWith
    // ==========================================
    group('copyWith', () {
      test('actualiza estadoInforme correctamente', () {
        final actualizado = informeCompleto.copyWith(
          estadoInforme: EstadoInforme.EMITIDO,
        );
        expect(actualizado.estadoInforme, EstadoInforme.EMITIDO);
        expect(actualizado.informeId, informeCompleto.informeId);
        expect(actualizado.loteId, informeCompleto.loteId);
      });

      test('actualiza urlPdf correctamente', () {
        const url = 'https://storage.googleapis.com/test/informe.pdf';
        final actualizado = informeCompleto.copyWith(urlPdf: url);
        expect(actualizado.urlPdf, url);
        expect(actualizado.estadoInforme, informeCompleto.estadoInforme);
      });

      test('actualiza fechaEmision correctamente', () {
        final fecha = DateTime(2026, 3, 15);
        final actualizado = informeCompleto.copyWith(fechaEmision: fecha);
        expect(actualizado.fechaEmision, fecha);
      });

      test('mantiene campos no modificados intactos', () {
        final actualizado = informeCompleto.copyWith(
          estadoInforme: EstadoInforme.EXPORTADO,
        );
        expect(actualizado.nombrePredioReportado,
            informeCompleto.nombrePredioReportado);
        expect(actualizado.nombreTitularReportado,
            informeCompleto.nombreTitularReportado);
        expect(actualizado.periodoReportado,
            informeCompleto.periodoReportado);
        expect(actualizado.anioReporte, informeCompleto.anioReporte);
      });
    });
  });
}