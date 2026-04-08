import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/registro_especie.dart';
import '../../data/repositories/informes_repository.dart';

class RegistroEspeciePage extends StatefulWidget {
  const RegistroEspeciePage({super.key});

  @override
  State<RegistroEspeciePage> createState() => _RegistroEspeciePageState();
}

class _RegistroEspeciePageState extends State<RegistroEspeciePage> {
  final _formKey = GlobalKey<FormState>();
  final _repository = InformesRepository();
  final _uuid = const Uuid();

  final _especieController = TextEditingController();
  final _variedadController = TextEditingController();
  final _lotesController = TextEditingController();
  final _plantasController = TextEditingController();
  final _produccionController = TextEditingController();
  final _porcentajeController = TextEditingController();

  String? _informeId;
  String _fenologia = 'Vegetativo';
  String _estadoFitosanitario = 'Bueno';
  String _unidadProduccion = 'kg';
  String _frecuenciaMonitoreo = 'Semanal';
  DateTime? _fechaSiembra;
  bool _isSaving = false;

  final List<String> _fenologias = [
    'Vegetativo', 'Floración', 'Fructificación',
    'Maduración', 'Cosecha', 'Poscosecha',
  ];

  final List<String> _estadosFitosanitarios = [
    'Bueno', 'Regular', 'Malo',
  ];

  final List<String> _frecuencias = [
    'Diario', 'Semanal', 'Quincenal', 'Mensual',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) _informeId = args;
  }

  @override
  void dispose() {
    _especieController.dispose();
    _variedadController.dispose();
    _lotesController.dispose();
    _plantasController.dispose();
    _produccionController.dispose();
    _porcentajeController.dispose();
    super.dispose();
  }

  Future<void> _selectFechaSiembra() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _fechaSiembra = picked);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate() || _informeId == null) return;
    setState(() => _isSaving = true);

    try {
      final registro = RegistroEspecie(
        registroId: _uuid.v4(),
        especieVegetal: _especieController.text.trim(),
        variedad: _variedadController.text.trim().isEmpty
            ? null
            : _variedadController.text.trim(),
        numeroLotesOTotes: _lotesController.text.trim().isEmpty
            ? null
            : int.tryParse(_lotesController.text.trim()),
        fechaSiembra: _fechaSiembra,
        numeroPlantas: _plantasController.text.trim().isEmpty
            ? null
            : int.tryParse(_plantasController.text.trim()),
        fenologia: _fenologia,
        estadoFitosanitario: _estadoFitosanitario,
        produccionEstimada: _produccionController.text.trim().isEmpty
            ? null
            : double.tryParse(
                _produccionController.text.trim().replaceAll(',', '.')),
        unidadProduccion: _unidadProduccion,
        frecuenciaMonitoreo: _frecuenciaMonitoreo,
        porcentajeArea: _porcentajeController.text.trim().isEmpty
            ? null
            : double.tryParse(
                _porcentajeController.text.trim().replaceAll(',', '.')),
      );

      await _repository.guardarRegistroEspecie(
        informeId: _informeId!,
        registro: registro,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  InputDecoration _inputDec(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD7DED3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFF2E7D32), width: 1.4),
        ),
      );

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2E7D32);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F5),
      appBar: AppBar(
        title: const Text('Registrar cultivo'),
        backgroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _especieController,
              decoration: _inputDec('Especie vegetal *'),
              validator: (v) =>
                  v!.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _variedadController,
              decoration: _inputDec('Variedad (opcional)'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _lotesController,
              keyboardType: TextInputType.number,
              decoration: _inputDec('Número de lotes o totes'),
            ),
            const SizedBox(height: 14),
            ListTile(
              title: const Text('Fecha de siembra'),
              subtitle: Text(
                _fechaSiembra != null
                    ? '${_fechaSiembra!.day}/${_fechaSiembra!.month}/${_fechaSiembra!.year}'
                    : 'No seleccionada',
              ),
              trailing: const Icon(Icons.calendar_today),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Color(0xFFD7DED3)),
                borderRadius: BorderRadius.circular(14),
              ),
              tileColor: Colors.white,
              onTap: _selectFechaSiembra,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _plantasController,
              keyboardType: TextInputType.number,
              decoration: _inputDec('Número de plantas/árboles'),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _fenologia,
              decoration: _inputDec('Fenología'),
              items: _fenologias
                  .map((f) =>
                      DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (val) => setState(() => _fenologia = val!),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _estadoFitosanitario,
              decoration: _inputDec('Estado fitosanitario'),
              items: _estadosFitosanitarios
                  .map((e) =>
                      DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) =>
                  setState(() => _estadoFitosanitario = val!),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _produccionController,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: _inputDec('Producción estimada'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _unidadProduccion,
                    decoration: _inputDec('Unidad'),
                    items: ['kg', 't', 'cajas', 'unidades', 'bultos']
                        .map((u) => DropdownMenuItem(
                            value: u, child: Text(u)))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _unidadProduccion = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _frecuenciaMonitoreo,
              decoration: _inputDec('Frecuencia de monitoreo'),
              items: _frecuencias
                  .map((f) =>
                      DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (val) =>
                  setState(() => _frecuenciaMonitoreo = val!),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _porcentajeController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: _inputDec('% porcentaje exportable del área (opcional)'),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _guardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Guardar cultivo',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}