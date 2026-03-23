import 'package:flutter/material.dart';
import 'package:mobile_app/features/lotes/data/repositories/lotes_repository.dart';
import '../../domain/models/lote.dart';

class LoteDetailPage extends StatefulWidget {
  const LoteDetailPage({super.key});

  @override
  State<LoteDetailPage> createState() => _LoteDetailPageState();
}

class _LoteDetailPageState extends State<LoteDetailPage> {
  Lote? _lote;

   bool _wasUpdated = false;

   Future<void> _goToEditLote() async {
  if (_lote == null) return;

  final result = await Navigator.pushNamed(
    context,
    '/lotes/edit',
    arguments: _lote,
  );

  if (!mounted) return;

  if (result is Lote) {
    setState(() {
      _lote = result;
      _wasUpdated = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lote actualizado')),
    );
  }
}


Future<void> _archiveLote() async {
  if (_lote == null) return;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Archivar lote'),
        content: const Text(
          'Este lote dejará de estar activo para nuevas operaciones. '
          'La información histórica se conservará.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Archivar'),
          ),
        ],
      );
    },
  );

  if (confirmed != true) return;

  try {
    await LotesRepository().updateEstadoLote(
      loteId: _lote!.loteId,
      estadoLote: 'ARCHIVADO',
    );

    if (!mounted) return;

    setState(() {
      _lote = Lote(
        loteId: _lote!.loteId,
        predioId: _lote!.predioId,
        productorId: _lote!.productorId,
        nombreLote: _lote!.nombreLote,
        codigoLote: _lote!.codigoLote,
        areaHectareas: _lote!.areaHectareas,
        especieVegetalActual: _lote!.especieVegetalActual,
        variedadActual: _lote!.variedadActual,
        estadoLote: 'ARCHIVADO',
        observaciones: _lote!.observaciones,
        createdAt: _lote!.createdAt,
        updatedAt: _lote!.updatedAt,
      );
      _wasUpdated = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lote archivado correctamente')),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No fue posible archivar el lote: $e')),
    );
  }
}

Future<void> _changeEstadoLote(String nuevoEstado) async {
  if (_lote == null) return;

  final bool archivando = nuevoEstado == 'ARCHIVADO';

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(archivando ? 'Archivar lote' : 'Activar lote'),
        content: Text(
          archivando
              ? 'El lote dejará de estar disponible para nuevos eventos, pero conservará su historial.'
              : 'El lote volverá a estar activo y permitirá nuevos eventos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(archivando ? 'Archivar' : 'Activar'),
          ),
        ],
      );
    },
  );

  if (confirmed != true) return;

  try {
    await LotesRepository().updateEstadoLote(
      loteId: _lote!.loteId,
      estadoLote: nuevoEstado,
    );

    if (!mounted) return;

    setState(() {
      _lote = Lote(
        loteId: _lote!.loteId,
        predioId: _lote!.predioId,
        productorId: _lote!.productorId,
        nombreLote: _lote!.nombreLote,
        codigoLote: _lote!.codigoLote,
        areaHectareas: _lote!.areaHectareas,
        especieVegetalActual: _lote!.especieVegetalActual,
        variedadActual: _lote!.variedadActual,
        estadoLote: nuevoEstado,
        observaciones: _lote!.observaciones,
        createdAt: _lote!.createdAt,
        updatedAt: _lote!.updatedAt,
      );
      _wasUpdated = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          archivando
              ? 'Lote archivado correctamente'
              : 'Lote activado correctamente',
        ),
      ),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('No fue posible actualizar el estado del lote: $e'),
      ),
    );
  }
}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Lote) {
      _lote = args;
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF7F9F5);
    const text = Color(0xFF1F2937);
    const softText = Color(0xFF6B7280);
    const primary = Color(0xFF2E7D32);

    if (_lote == null) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(title: const Text('Detalle del lote')),
        body: const Center(
          child: Text('No se recibió información del lote'),
        ),
      );
    }

    final subtitle = _lote!.variedadActual != null && _lote!.variedadActual!.trim().isNotEmpty
        ? '${_lote!.especieVegetalActual} · ${_lote!.variedadActual}'
        : _lote!.especieVegetalActual;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
  title: const Text('Detalle del lote'),
  leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () {
      Navigator.pop(context, _wasUpdated ? _lote : null);
    },
  ),
  actions: [
  IconButton(
    onPressed: _goToEditLote,
    icon: const Icon(Icons.edit_outlined),
    tooltip: 'Editar lote',
  ),
  IconButton(
    onPressed: () => _changeEstadoLote(
      _lote?.estadoLote == 'ACTIVO' ? 'ARCHIVADO' : 'ACTIVO',
    ),
    icon: Icon(
      _lote?.estadoLote == 'ACTIVO'
          ? Icons.archive_outlined
          : Icons.unarchive_outlined,
    ),
    tooltip: _lote?.estadoLote == 'ACTIVO'
        ? 'Archivar lote'
        : 'Activar lote',
  ),
],
),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_lote!.codigoLote != null && _lote!.codigoLote!.trim().isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF4E7),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _lote!.codigoLote!,
                      style: const TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                const SizedBox(height: 14),
                Text(
                  _lote!.nombreLote,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_lote!.areaHectareas} ha · ${_lote!.estadoLote}',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _ActionCard(
  icon: Icons.eco_outlined,
  title: 'Registrar evento',
  description: 'Inicia el registro del evento agrícola desde este lote.',
  onTap: _lote!.estadoLote == 'ACTIVO'
      ? () {
          // Navegamos al selector pasando el lote actual
          Navigator.pushNamed(
            context,
            '/eventos/seleccionar',
            arguments: _lote,
          );
        }
      : () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('El lote está archivado y no permite nuevos eventos'),
            ),
          );
        },
),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionCard(
                  icon: Icons.history,
                  title: 'Ver historial',
                  description: 'Consulta la trazabilidad histórica de este lote.',
                  onTap: () {
  Navigator.pushNamed(
    context,
    '/lotes/historial',
    arguments: _lote,
  );
},
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFD7DED3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumen del lote',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: text,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  runSpacing: 10,
                  spacing: 10,
                  children: [
                    _SummaryBox(label: 'Área', value: '${_lote!.areaHectareas} ha'),
                    _SummaryBox(label: 'Estado', value: _lote!.estadoLote),
                    _SummaryBox(label: 'Especie actual', value: _lote!.especieVegetalActual),
                    _SummaryBox(
                      label: 'Variedad',
                      value: _lote!.variedadActual?.trim().isNotEmpty == true
                          ? _lote!.variedadActual!
                          : '-',
                    ),
                  ],
                ),
                if (_lote!.observaciones != null && _lote!.observaciones!.trim().isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const Text(
                    'Observaciones',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _lote!.observaciones!,
                    style: const TextStyle(
                      color: softText,
                      height: 1.45,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const border = Color(0xFFD7DED3);
    const text = Color(0xFF1F2937);
    const softText = Color(0xFF6B7280);
    const primary = Color(0xFF2E7D32);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: primary),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: softText,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryBox({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF4F7F2);
    const text = Color(0xFF1F2937);
    const softText = Color(0xFF6B7280);

    return Container(
      width: 155,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: softText)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: text,
            ),
          ),
        ],
      ),
    );
  }
}