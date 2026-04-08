import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/informe_sanitario.dart';
import '../../data/repositories/informes_repository.dart';
import '../../../lotes/domain/models/lote.dart';
import '../../../predios/domain/models/predio.dart';
import '../../../predios/data/repositories/predios_repository.dart';
import '../../../auth/domain/models/productor.dart';
import '../../../home/data/repositories/dashboard_repository.dart';

class InformesListPage extends StatefulWidget {
  const InformesListPage({super.key});

  @override
  State<InformesListPage> createState() => _InformesListPageState();
}

class _InformesListPageState extends State<InformesListPage> {
  final InformesRepository _repository = InformesRepository();
  final DashboardRepository _dashboardRepo = DashboardRepository();
  final PrediosRepository _prediosRepo = PrediosRepository();

  Lote? _lote;
  Predio? _predio;
  Productor? _productor;
  List<InformeFitosanitario> _informes = [];
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Lote && _lote == null) {
      _lote = args;
      _cargarDatos();
    }
  }

  Future<void> _cargarDatos() async {
    if (_lote == null) return;
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final results = await Future.wait([
        _dashboardRepo.getProductor(user.uid),
        _prediosRepo.getPredioById(_lote!.predioId),
        _repository.getInformesByLote(_lote!.loteId, user.uid),
      ]);

      if (!mounted) return;
      setState(() {
        _productor = results[0] as Productor?;
        _predio = results[1] as Predio?;
        _informes = results[2] as List<InformeFitosanitario>;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _crearInforme() async {
    if (_lote == null || _predio == null || _productor == null) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _DialogSeleccionarPeriodo(),
    );

    if (result == null || !mounted) return;

    try {
      final informeId = await _repository.crearInforme(
        lote: _lote!,
        predio: _predio!,
        productor: _productor!,
        periodo: result['periodo'] as PeriodoReportado,
        anio: result['anio'] as int,
      );

      if (!mounted) return;

      Navigator.pushNamed(
        context,
        '/informes/detalle',
        arguments: informeId,
      ).then((_) => _cargarDatos());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF7F9F5);
    const primary = Color(0xFF2E7D32);
    const text = Color(0xFF1F2937);
    const softText = Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Informes ICA'),
        backgroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primary))
          : Column(
              children: [
                if (_lote != null)
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _lote!.nombreLote,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: text,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_lote!.especieVegetalActual} · ${_lote!.areaHectareas} ha',
                          style: const TextStyle(
                            fontSize: 14,
                            color: softText,
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: _informes.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _informes.length,
                          itemBuilder: (context, index) {
                            return _InformeCard(
                              informe: _informes[index],
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/informes/detalle',
                                  arguments: _informes[index].informeId,
                                ).then((_) => _cargarDatos());
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: FloatingActionButton.extended(
            onPressed: _crearInforme,
            backgroundColor: primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text(
              'Nuevo informe',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'Aún no hay informes ICA',
            style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Crea el primer informe trisemestral\npara este lote.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }
}

class _InformeCard extends StatelessWidget {
  final InformeFitosanitario informe;
  final VoidCallback onTap;

  const _InformeCard({required this.informe, required this.onTap});

  Color _getColorEstado(EstadoInforme estado) {
    switch (estado) {
      case EstadoInforme.BORRADOR:
        return Colors.orange.shade700;
      case EstadoInforme.EMITIDO:
        return Colors.blue.shade700;
      case EstadoInforme.EXPORTADO:
        return const Color(0xFF2E7D32);
    }
  }

  String _getLabelEstado(EstadoInforme estado) {
    switch (estado) {
      case EstadoInforme.BORRADOR:
        return 'Borrador';
      case EstadoInforme.EMITIDO:
        return 'Generando PDF...';
      case EstadoInforme.EXPORTADO:
        return 'PDF listo';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorEstado = _getColorEstado(informe.estadoInforme);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD7DED3)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      informe.periodoLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorEstado.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _getLabelEstado(informe.estadoInforme),
                      style: TextStyle(
                        color: colorEstado,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Año ${informe.anioReporte} · ${informe.especieVegetalReportada}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              if (informe.estadoInforme == EstadoInforme.EXPORTADO) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.qr_code, size: 16, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 6),
                    const Text(
                      'QR disponible',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogSeleccionarPeriodo extends StatefulWidget {
  @override
  State<_DialogSeleccionarPeriodo> createState() =>
      _DialogSeleccionarPeriodoState();
}

class _DialogSeleccionarPeriodoState extends State<_DialogSeleccionarPeriodo> {
  PeriodoReportado _periodoSeleccionado = PeriodoReportado.FEB_MAR_ABR;
  int _anioSeleccionado = DateTime.now().year;

  String _labelPeriodo(PeriodoReportado p) {
    switch (p) {
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

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2E7D32);

    return AlertDialog(
      title: const Text(
        'Nuevo informe ICA',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Periodo trisemestral',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<PeriodoReportado>(
            value: _periodoSeleccionado,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 12),
            ),
            items: PeriodoReportado.values
                .map((p) => DropdownMenuItem(
                      value: p,
                      child: Text(
                        _labelPeriodo(p),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ))
                .toList(),
            onChanged: (val) =>
                setState(() => _periodoSeleccionado = val!),
          ),
          const SizedBox(height: 16),
          const Text(
            'Año',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: _anioSeleccionado,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 12),
            ),
            items: [
              DateTime.now().year - 1,
              DateTime.now().year,
              DateTime.now().year + 1,
            ]
                .map((a) => DropdownMenuItem(
                      value: a,
                      child: Text('$a'),
                    ))
                .toList(),
            onChanged: (val) =>
                setState(() => _anioSeleccionado = val!),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, {
            'periodo': _periodoSeleccionado,
            'anio': _anioSeleccionado,
          }),
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Crear'),
        ),
      ],
    );
  }
}