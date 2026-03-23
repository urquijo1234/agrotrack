import 'package:flutter/material.dart';
import '../../../lotes/domain/models/lote.dart';
import '../../domain/models/evento_agricola.dart';
import '../../data/repositories/eventos_repository.dart';

class SiembraCreatePage extends StatefulWidget {
  const SiembraCreatePage({super.key});

  @override
  State<SiembraCreatePage> createState() => _SiembraCreatePageState();
}

class _SiembraCreatePageState extends State<SiembraCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _repository = EventosRepository();

  final _especieController = TextEditingController();
  final _variedadController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _areaController = TextEditingController();
  final _origenController = TextEditingController();
  final _observacionesController = TextEditingController();
  
  String _unidadCantidad = 'kg'; // Valor por defecto
  DateTime _fechaSiembra = DateTime.now();
  bool _isSaving = false;
  Lote? _lote;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Lote) {
      _lote = args;
      // Pre-llenamos con los datos actuales del lote por comodidad
      if (_especieController.text.isEmpty) {
        _especieController.text = _lote!.especieVegetalActual;
      }
      if (_variedadController.text.isEmpty && _lote!.variedadActual != null) {
        _variedadController.text = _lote!.variedadActual!;
      }
    }
  }

  @override
  void dispose() {
    _especieController.dispose();
    _variedadController.dispose();
    _cantidadController.dispose();
    _areaController.dispose();
    _origenController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaSiembra,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _fechaSiembra) {
      setState(() {
        _fechaSiembra = picked;
      });
    }
  }

  Future<void> _saveSiembra() async {
    if (!_formKey.currentState!.validate() || _lote == null) return;
    setState(() => _isSaving = true);

    try {
      final cantidad = double.parse(_cantidadController.text.trim().replaceAll(',', '.'));
      final area = double.parse(_areaController.text.trim().replaceAll(',', '.'));

      // Creamos el Payload específico de Siembra (Tabla 5)
      final detalleSiembra = {
        'especieVegetal': _especieController.text.trim(),
        'variedad': _variedadController.text.trim().isNotEmpty ? _variedadController.text.trim() : null,
        'fechaSiembra': _fechaSiembra.toIso8601String(),
        'cantidadSembrada': cantidad,
        'unidadCantidad': _unidadCantidad,
        'areaSembradaHa': area,
        'origenSemilla': _origenController.text.trim().isNotEmpty ? _origenController.text.trim() : null,
        'observaciones': _observacionesController.text.trim().isNotEmpty ? _observacionesController.text.trim() : null,
      };

      final evento = EventoAgricola(
        eventoId: '', // Se generará el UUID en el repositorio
        loteId: _lote!.loteId,
        predioId: _lote!.predioId,
        productorId: _lote!.productorId,
        tipoEvento: TipoEvento.SIEMBRA,
        fechaEvento: _fechaSiembra,
        descripcion: 'Siembra de ${_especieController.text.trim()}',
        detalleEvento: detalleSiembra,
      );

      // El repositorio guarda en SQLite e intenta el push a Firestore
      await _repository.createEvento(evento);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Siembra registrada. (Sincronización en segundo plano)')),
      );
      Navigator.pop(context, true); // Regresamos al selector
     
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_lote == null) return const Scaffold(body: Center(child: Text('Error: Lote no provisto')));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F5),
      appBar: AppBar(title: const Text('Registrar Siembra')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Fecha
            ListTile(
              title: const Text('Fecha de Siembra'),
              subtitle: Text("${_fechaSiembra.day}/${_fechaSiembra.month}/${_fechaSiembra.year}"),
              trailing: const Icon(Icons.calendar_today),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Color(0xFFD7DED3)),
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: Colors.white,
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 16),
            
            // Especie
            TextFormField(
              controller: _especieController,
              decoration: const InputDecoration(
                labelText: 'Especie Vegetal *', filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),

            // Variedad
            TextFormField(
              controller: _variedadController,
              decoration: const InputDecoration(
                labelText: 'Variedad (Opcional)', filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Cantidad y Unidad
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _cantidadController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Cantidad *', filled: true, fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _unidadCantidad,
                    decoration: const InputDecoration(
                      labelText: 'Unidad', filled: true, fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    items: ['kg', 'g', 'lb', 'plantas', 'semillas']
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (val) => setState(() => _unidadCantidad = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Área
            TextFormField(
              controller: _areaController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Área sembrada (ha) *', filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 32),

            // Botón Guardar
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveSiembra,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                ),
                child: _isSaving 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('Guardar Siembra', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}