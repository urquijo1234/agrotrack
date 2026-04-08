import 'package:flutter/material.dart';
import '../../domain/models/informe_sanitario.dart';
import '../../domain/models/registro_especie.dart';
import '../../data/repositories/informes_repository.dart';

class InformeDetallePage extends StatefulWidget {
  const InformeDetallePage({super.key});

  @override
  State<InformeDetallePage> createState() => _InformeDetallePageState();
}

class _InformeDetallePageState extends State<InformeDetallePage> {
  final InformesRepository _repository = InformesRepository();

  String? _informeId;
  InformeFitosanitario? _informe;
  List<RegistroEspecie> _registros = [];
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && _informeId == null) {
      _informeId = args;
      _cargarInforme();
    }
  }

  Future<void> _cargarInforme() async {
    if (_informeId == null) return;
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _repository.getInformeById(_informeId!),
        _repository.getRegistrosEspecie(_informeId!),
      ]);

      if (!mounted) return;
      setState(() {
        _informe = results[0] as InformeFitosanitario?;
        _registros = results[1] as List<RegistroEspecie>;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _irAChecklist() async {
    await Navigator.pushNamed(
      context,
      '/informes/checklist',
      arguments: _informeId,
    );
    _cargarInforme();
  }

  Future<void> _agregarRegistroEspecie() async {
    await Navigator.pushNamed(
      context,
      '/informes/registro_especie',
      arguments: _informeId,
    );
    _cargarInforme();
  }

  Future<void> _emitirInforme() async {
    if (_informe == null) return;

    if (_registros.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Debe agregar al menos un registro de especie antes de emitir.'),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emitir informe'),
        content: const Text(
          'Al emitir el informe se generará el PDF y el código QR. '
          'No podrá modificar el informe después de emitirlo. '
          '¿Desea continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
            child: const Text('Emitir'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _repository.emitirInforme(_informeId!);
      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        '/informes/qr',
        arguments: _informeId,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al emitir: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF7F9F5);
    const primary = Color(0xFF2E7D32);
    const text = Color(0xFF1F2937);
    const softText = Color(0xFF6B7280);

    final esBorrador = _informe?.estadoInforme == EstadoInforme.BORRADOR;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Informe ICA'),
        backgroundColor: Colors.white,
        actions: [
          if (_informe?.estadoInforme != EstadoInforme.BORRADOR)
            IconButton(
              icon: const Icon(Icons.qr_code),
              tooltip: 'Ver QR',
              onPressed: () => Navigator.pushNamed(
                context,
                '/informes/qr',
                arguments: _informeId,
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primary))
          : _informe == null
              ? const Center(child: Text('Informe no encontrado'))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  children: [
                    // Encabezado del informe
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _informe!.periodoLabel,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Año ${_informe!.anioReporte}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _InfoFilaPDF(
                              label: 'Predio',
                              value: _informe!.nombrePredioReportado),
                          _InfoFilaPDF(
                              label: 'Titular',
                              value: _informe!.nombreTitularReportado),
                          _InfoFilaPDF(
                              label: 'Ubicación',
                              value:
                                  '${_informe!.municipioReportado}, ${_informe!.departamentoReportado}'),
                          if (_informe!.numeroRegistroICA != null)
                            _InfoFilaPDF(
                                label: 'Reg. ICA',
                                value: _informe!.numeroRegistroICA!),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sección registros especie
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Cultivos reportados',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: text,
                          ),
                        ),
                        if (esBorrador)
                          TextButton.icon(
                            onPressed: _agregarRegistroEspecie,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Agregar'),
                            style: TextButton.styleFrom(
                              foregroundColor: primary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (_registros.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFD7DED3)),
                        ),
                        child: const Text(
                          'Aún no hay cultivos registrados. Agrega al menos uno.',
                          style: TextStyle(color: Color(0xFF6B7280)),
                        ),
                      )
                    else
                      ..._registros.map(
                        (r) => _RegistroCard(registro: r),
                      ),

                    const SizedBox(height: 24),

                    // Sección checklist
                    const Text(
                      'Checklist ICA',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFD7DED3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.checklist,
                                color: primary, size: 24),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Preguntas de inspección',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: text,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Secciones V, VI, VII e INFO — 64 ítems',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: softText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (esBorrador)
                            ElevatedButton(
                              onPressed: _irAChecklist,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Diligenciar'),
                            )
                          else
                            ElevatedButton(
                              onPressed: _irAChecklist,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade200,
                                foregroundColor: Colors.grey.shade700,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Ver'),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: esBorrador
          ? Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              color: Colors.white,
              child: SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _emitirInforme,
                  icon: const Icon(Icons.send),
                  label: const Text(
                    'Emitir informe y generar PDF',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _InfoFilaPDF extends StatelessWidget {
  final String label;
  final String value;

  const _InfoFilaPDF({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegistroCard extends StatelessWidget {
  final RegistroEspecie registro;

  const _RegistroCard({required this.registro});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD7DED3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            registro.especieVegetal,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: Color(0xFF1F2937),
            ),
          ),
          if (registro.variedad != null) ...[
            const SizedBox(height: 4),
            Text(
              'Variedad: ${registro.variedad}',
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ],
          if (registro.numeroPlantas != null) ...[
            const SizedBox(height: 4),
            Text(
              '${registro.numeroPlantas} plantas · ${registro.fenologia ?? ''}',
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ],
        ],
      ),
    );
  }
}