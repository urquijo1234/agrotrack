import 'package:flutter/material.dart';
import '../../domain/models/evento_agricola.dart';
import '../../data/repositories/eventos_repository.dart';
import '../widgets/evento_card.dart';

class SyncQueuePage extends StatefulWidget {
  const SyncQueuePage({super.key});

  @override
  State<SyncQueuePage> createState() => _SyncQueuePageState();
}

class _SyncQueuePageState extends State<SyncQueuePage> {
  final EventosRepository _repository = EventosRepository();
  List<EventoAgricola> _pendingEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQueue();
  }

  Future<void> _loadQueue() async {
    setState(() => _isLoading = true);
    try {
      final events = await _repository.getPendingEvents();
      if (mounted) {
        setState(() {
          _pendingEvents = events;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF7F9F5);
    const primary = Color(0xFF2E7D32);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Cola de Sincronización'),
        backgroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primary))
          : _pendingEvents.isEmpty
              ? const Center(
                  child: Text(
                    'No hay eventos pendientes.\nTodo está en la nube ☁️',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pendingEvents.length,
                  itemBuilder: (context, index) {
                    final evento = _pendingEvents[index];
                    return EventoCard(
                      evento: evento,
                      onTap: () {
                        // Opcional: Navegar al detalle para verlo
                        Navigator.pushNamed(context, '/eventos/detalle', arguments: evento);
                      },
                    );
                  },
                ),
    );
  }
}