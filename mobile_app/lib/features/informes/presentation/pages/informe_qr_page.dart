import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../domain/models/informe_sanitario.dart';
import '../../data/repositories/informes_repository.dart';

class InformeQrPage extends StatefulWidget {
  const InformeQrPage({super.key});

  @override
  State<InformeQrPage> createState() => _InformeQrPageState();
}

class _InformeQrPageState extends State<InformeQrPage> {
  final InformesRepository _repository = InformesRepository();

  String? _informeId;
  InformeFitosanitario? _informe;
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && _informeId == null) {
      _informeId = args;
      _cargarInforme();
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _cargarInforme() async {
    if (_informeId == null) return;

    final informe = await _repository.getInformeById(_informeId!);
    if (!mounted) return;

    setState(() {
      _informe = informe;
      _isLoading = false;
    });

    // Si está EMITIDO pero sin PDF todavía, hacer polling cada 5 segundos
    if (informe?.estadoInforme == EstadoInforme.EMITIDO &&
        informe?.urlPdf == null) {
      _iniciarPolling();
    }
  }

  void _iniciarPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (_informeId == null) return;

      final informe = await _repository.getInformeById(_informeId!);
      if (!mounted) return;

      if (informe?.urlPdf != null) {
        _pollingTimer?.cancel();
        setState(() => _informe = informe);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2E7D32);
    const bg = Color(0xFFF7F9F5);
    const text = Color(0xFF1F2937);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('QR del Informe'),
        backgroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primary))
          : _informe == null
              ? const Center(child: Text('Informe no encontrado'))
              : ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Cabecera
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.description_outlined,
                            color: Colors.white,
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _informe!.periodoLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Año ${_informe!.anioReporte} · ${_informe!.nombrePredioReportado}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // QR o estado de generación
                    if (_informe!.urlPdf != null) ...[
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFFD7DED3)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: QrImageView(
                            data: _informe!.urlPdf!,
                            version: QrVersions.auto,
                            size: 240,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDF7EE),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle,
                                    color: Color(0xFF2E7D32), size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'PDF generado y listo',
                                  style: TextStyle(
                                    color: Color(0xFF2E7D32),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _informe!.urlPdf!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF6B7280),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Escanea el código QR para ver el informe en el navegador. '
                        'Puedes compartirlo con el inspector del ICA.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                          height: 1.5,
                        ),
                      ),
                    ] else ...[
                      // PDF todavía generándose
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: const Color(0xFFD7DED3)),
                        ),
                        child: Column(
                          children: [
                            const CircularProgressIndicator(
                                color: primary),
                            const SizedBox(height: 20),
                            const Text(
                              'Generando PDF...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: text,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'AgroTrack está procesando el informe. '
                              'El QR aparecerá automáticamente cuando esté listo.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
    );
  }
}