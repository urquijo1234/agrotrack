import 'package:flutter/material.dart';
import '../../../lotes/domain/models/lote.dart';
import '../../domain/models/evento_agricola.dart';
import '../../data/repositories/eventos_repository.dart';

class CosechaCreatePage extends StatefulWidget {
  const CosechaCreatePage({super.key});

  @override
  State<CosechaCreatePage> createState() => _CosechaCreatePageState();
}

class _CosechaCreatePageState extends State<CosechaCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _repository = EventosRepository();

  final _especieController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _areaCosechadaController = TextEditingController();
  final _destinoController = TextEditingController();
  final _responsableController = TextEditingController();
  final _observacionesController = TextEditingController();

  DateTime _fechaCosecha = DateTime.now();
  String _unidadProduccion = 'kg';
  
  bool _isSaving = false;
  Lote? _lote;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Lote) {
      _lote = args;
      if (_especieController.text.isEmpty) {
        _especieController.text = _lote!.especieVegetalActual;
      }
    }
  }

  @override
  void dispose() {
    _especieController.dispose();
    _cantidadController.dispose();
    _areaCosechadaController.dispose();
    _destinoController.dispose();
    _responsableController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaCosecha,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _fechaCosecha) {
      setState(() => _fechaCosecha = picked);
    }
  }

  Future<void> _saveCosecha() async {
    if (!_formKey.currentState!.validate() || _lote == null) return;
    setState(() => _isSaving = true);

    try {
      final cantidad = double.parse(_cantidadController.text.trim().replaceAll(',', '.'));
      final areaCosechada = double.parse(_areaCosechadaController.text.trim().replaceAll(',', '.'));

      // Payload exacto según Tabla 7
      final detalleCosecha = {
        'especieVegetal': _especieController.text.trim(),
        'fechaCosecha': _fechaCosecha.toIso8601String(),
        'cantidadCosechada': cantidad,
        'unidadProduccion': _unidadProduccion,
        'areaCosechadaHa': areaCosechada,
        'destinoProduccion': _destinoController.text.trim().isNotEmpty ? _destinoController.text.trim() : null,
        'responsableCosecha': _responsableController.text.trim().isNotEmpty ? _responsableController.text.trim() : null,
        'observaciones': _observacionesController.text.trim().isNotEmpty ? _observacionesController.text.trim() : null,
      };

      final evento = EventoAgricola(
        eventoId: '', 
        loteId: _lote!.loteId,
        predioId: _lote!.predioId,
        productorId: _lote!.productorId,
        tipoEvento: TipoEvento.COSECHA,
        fechaEvento: _fechaCosecha,
        descripcion: 'Cosecha de ${_especieController.text.trim()} ($cantidad $_unidadProduccion)',
        detalleEvento: detalleCosecha,
      );

      await _repository.createEvento(evento);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cosecha registrada exitosamente.')),
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
      appBar: AppBar(title: const Text('Registrar Cosecha')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              title: const Text('Fecha de Cosecha'),
              subtitle: Text("${_fechaCosecha.day}/${_fechaCosecha.month}/${_fechaCosecha.year}"),
              trailing: const Icon(Icons.calendar_today),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Color(0xFFD7DED3)),
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: Colors.white,
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _especieController,
              decoration: const InputDecoration(labelText: 'Especie Cosechada *', filled: true, fillColor: Colors.white, border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _cantidadController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Cantidad *', filled: true, fillColor: Colors.white, border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _unidadProduccion,
                    decoration: const InputDecoration(labelText: 'Unidad', filled: true, fillColor: Colors.white, border: OutlineInputBorder()),
                    items: ['kg', 't', 'cajas', 'piñas', 'unidades', 'bultos']
                        .map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                    onChanged: (val) => setState(() => _unidadProduccion = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _areaCosechadaController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Área cosechada (ha) *', filled: true, fillColor: Colors.white, border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _destinoController,
              decoration: const InputDecoration(labelText: 'Destino (ej. Mercado local, Exportación)', filled: true, fillColor: Colors.white, border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _responsableController,
              decoration: const InputDecoration(labelText: 'Responsable', filled: true, fillColor: Colors.white, border: OutlineInputBorder()),
            ),
            const SizedBox(height: 32),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveCosecha,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
                child: _isSaving 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('Guardar Cosecha', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}