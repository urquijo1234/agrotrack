import 'package:flutter/material.dart';
import '../../../lotes/domain/models/lote.dart';
import '../../domain/models/evento_agricola.dart';
import '../../data/repositories/eventos_repository.dart';
import '../widgets/evento_card.dart';

class LoteHistorialPage extends StatefulWidget {
  const LoteHistorialPage({super.key});

  @override
  State<LoteHistorialPage> createState() => _LoteHistorialPageState();
}

class _LoteHistorialPageState extends State<LoteHistorialPage> {
  final EventosRepository _repository = EventosRepository();
  Lote? _lote;
  
  List<EventoAgricola> _todosLosEventos = [];
  List<EventoAgricola> _eventosFiltrados = [];
  bool _isLoading = true;
  
  TipoEvento? _filtroActual; // null significa "Todos"

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Lote && _lote == null) {
      _lote = args;
      _cargarHistorial();
    }
  }

  Future<void> _cargarHistorial() async {
    if (_lote == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      // 1. Descargar de Firebase y actualizar SQLite
      // Pasamos tanto el loteId como el productorId
      await _repository.downloadEventosToLocal(_lote!.loteId, _lote!.productorId);

      // 2. Leer de SQLite
      final eventos = await _repository.getEventosByLote(_lote!.loteId);
      
      if (!mounted) return;
      setState(() {
        _todosLosEventos = eventos;
        _aplicarFiltro(_filtroActual);
        _isLoading = false;
      });
    } catch (e) {
      // ... manejo de errores ...
    }
  }

  void _aplicarFiltro(TipoEvento? tipo) {
    setState(() {
      _filtroActual = tipo;
      if (tipo == null) {
        _eventosFiltrados = _todosLosEventos;
      } else {
        _eventosFiltrados = _todosLosEventos.where((e) => e.tipoEvento == tipo).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF7F9F5);
    const primary = Color(0xFF2E7D32);

    if (_lote == null) {
      return const Scaffold(body: Center(child: Text('Error: Lote no provisto')));
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Historial del Lote'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera con filtros
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _FiltroChip(
                    label: 'Todos',
                    isSelected: _filtroActual == null,
                    onSelected: (v) => _aplicarFiltro(null),
                  ),
                  const SizedBox(width: 8),
                  _FiltroChip(
                    label: 'Siembras',
                    isSelected: _filtroActual == TipoEvento.SIEMBRA,
                    onSelected: (v) => _aplicarFiltro(v ? TipoEvento.SIEMBRA : null),
                  ),
                  const SizedBox(width: 8),
                  _FiltroChip(
                    label: 'Insumos',
                    isSelected: _filtroActual == TipoEvento.APLICACION_INSUMO,
                    onSelected: (v) => _aplicarFiltro(v ? TipoEvento.APLICACION_INSUMO : null),
                  ),
                  const SizedBox(width: 8),
                  _FiltroChip(
                    label: 'Cosechas',
                    isSelected: _filtroActual == TipoEvento.COSECHA,
                    onSelected: (v) => _aplicarFiltro(v ? TipoEvento.COSECHA : null),
                  ),
                ],
              ),
            ),
          ),
          
          // Lista de Eventos
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: primary))
                : _eventosFiltrados.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _eventosFiltrados.length,
                        itemBuilder: (context, index) {
                          final evento = _eventosFiltrados[index];
                          return EventoCard(
                            evento: evento,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/eventos/detalle',
                                arguments: evento,
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            _filtroActual == null 
              ? 'Aún no hay eventos registrados'
              : 'No hay eventos de este tipo',
            style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

// Widget auxiliar para los chips de filtro
class _FiltroChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const _FiltroChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2E7D32);
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: Colors.white,
      selectedColor: primary.withOpacity(0.15),
      labelStyle: TextStyle(
        color: isSelected ? primary : const Color(0xFF6B7280),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? primary : const Color(0xFFD7DED3),
        ),
      ),
      showCheckmark: false,
    );
  }
}