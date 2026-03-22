import 'package:flutter/material.dart';
import 'package:mobile_app/features/predios/data/repositories/predios_repository.dart';
import '../../../lotes/data/repositories/lotes_repository.dart';
import '../../../lotes/domain/models/lote.dart';
import '../../../lotes/presentation/widgets/lote_card.dart';
import '../../../lotes/presentation/widgets/lotes_empty_state.dart';
import '../../domain/models/predio.dart';
import '../widgets/predio_info_card.dart';

class PredioDetailPage extends StatefulWidget {
  const PredioDetailPage({super.key});

  @override
  State<PredioDetailPage> createState() => _PredioDetailPageState();
}

class _PredioDetailPageState extends State<PredioDetailPage> {
  final LotesRepository _lotesRepository = LotesRepository();

  Predio? _predio;
  bool _wasUpdated = false;
  late Future<List<Lote>> _futureLotes;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_predio == null) {
      final args = ModalRoute.of(context)?.settings.arguments;

      if (args is Predio) {
        _predio = args;
        _loadLotes();
      }
    }
  }

  void _loadLotes() {
  if (_predio == null) return;
  _futureLotes = _lotesRepository.getLotesByPredio(
    predioId: _predio!.predioId,
    productorId: _predio!.productorId,
  );
}
  Future<void> _goToEditPredio() async {
    if (_predio == null) return;

    final result = await Navigator.pushNamed(
      context,
      '/predios/edit',
      arguments: _predio,
    );

    if (!mounted) return;

    if (result is Predio) {
      setState(() {
        _predio = result;
        _wasUpdated = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Predio actualizado')),
      );
    }
  }

  Future<void> _goToCreateLote() async {

    if (_predio?.estadoPredio != 'ACTIVO') {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('El predio está archivado y no permite crear nuevos lotes'),
    ),
  );
  return;
}
    if (_predio == null) return;

    final created = await Navigator.pushNamed(
      context,
      '/lotes/create',
      arguments: _predio,
    );

    if (!mounted) return;

    if (created == true) {
      setState(() {
        _loadLotes();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lote creado correctamente')),
      );
    }
  }

  Future<void> _goToLoteDetail(Lote lote) async {
  final result = await Navigator.pushNamed(
    context,
    '/lotes/detail',
    arguments: lote,
  );

  if (!mounted) return;

  if (result is Lote) {
    setState(() {
      _loadLotes();
    });
  }
}

Future<void> _changeEstadoPredio(String nuevoEstado) async {
  if (_predio == null) return;

  final bool archivando = nuevoEstado == 'ARCHIVADO';

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(archivando ? 'Archivar predio' : 'Activar predio'),
        content: Text(
          archivando
              ? 'El predio dejará de estar disponible para nuevas operaciones, pero conservará su historial.'
              : 'El predio volverá a estar activo y permitirá nuevas operaciones.',
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
    await _lotesRepository; // no quitar si ya existe el repo arriba
    await PrediosRepository().updateEstadoPredio(
      predioId: _predio!.predioId,
      estadoPredio: nuevoEstado,
    );

    if (!mounted) return;

    setState(() {
      _predio = Predio(
        predioId: _predio!.predioId,
        productorId: _predio!.productorId,
        nombrePredio: _predio!.nombrePredio,
        numeroRegistroICA: _predio!.numeroRegistroICA,
        departamento: _predio!.departamento,
        municipio: _predio!.municipio,
        vereda: _predio!.vereda,
        areaRegistradaHa: _predio!.areaRegistradaHa,
        estadoPredio: nuevoEstado,
        createdAt: _predio!.createdAt,
        updatedAt: _predio!.updatedAt,
      );
      _wasUpdated = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          archivando
              ? 'Predio archivado correctamente'
              : 'Predio activado correctamente',
        ),
      ),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('No fue posible actualizar el estado del predio: $e'),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF7F9F5);
    const text = Color(0xFF1F2937);
    const softText = Color(0xFF6B7280);

    if (_predio == null) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(title: const Text('Detalle de predio')),
        body: const Center(
          child: Text('No se recibió información del predio'),
        ),
      );
    }

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          title: const Text('Detalle de predio'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, _wasUpdated ? _predio : null);
            },
          ),
          actions: [
  IconButton(
    onPressed: _goToEditPredio,
    icon: const Icon(Icons.edit_outlined),
    tooltip: 'Editar predio',
  ),
  IconButton(
    onPressed: () => _changeEstadoPredio(
      _predio?.estadoPredio == 'ACTIVO' ? 'ARCHIVADO' : 'ACTIVO',
    ),
    icon: Icon(
      _predio?.estadoPredio == 'ACTIVO'
          ? Icons.archive_outlined
          : Icons.unarchive_outlined,
    ),
    tooltip: _predio?.estadoPredio == 'ACTIVO'
        ? 'Archivar predio'
        : 'Activar predio',
  ),
],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            const Text(
              'Información general',
              style: TextStyle(fontSize: 14, color: softText),
            ),
            const SizedBox(height: 10),
            PredioInfoCard(predio: _predio!),
            const SizedBox(height: 20),
            const Text(
              'Lotes del predio',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: text,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Aquí verás las unidades productivas asociadas a este predio.',
              style: TextStyle(fontSize: 14, color: softText),
            ),
            const SizedBox(height: 14),
            FutureBuilder<List<Lote>>(
              future: _futureLotes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error al cargar lotes'),
                  );
                }

                final lotes = snapshot.data ?? [];

                if (lotes.isEmpty) {
                  return LotesEmptyState(
                    onCreateLote: _goToCreateLote,
                  );
                }

                return Column(
                  children: lotes
                      .map(
                        (lote) => LoteCard(
                          lote: lote,
                          onTap: () => _goToLoteDetail(lote),
                        ),
                      )
                      .toList(),
                );
              },
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
              onPressed: _predio?.estadoPredio == 'ACTIVO' ? _goToCreateLote : null,
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text(
                'Crear lote',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}