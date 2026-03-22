import 'package:flutter/material.dart';
import '../../../predios/domain/models/predio.dart';
import '../../data/repositories/lotes_repository.dart';
import '../../domain/models/lote.dart';
import '../widgets/lote_form.dart';

class LoteCreatePage extends StatefulWidget {
  const LoteCreatePage({super.key});

  @override
  State<LoteCreatePage> createState() => _LoteCreatePageState();
}

class _LoteCreatePageState extends State<LoteCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _repository = LotesRepository();

  final _nombreController = TextEditingController();
  final _codigoController = TextEditingController();
  final _areaController = TextEditingController();
  final _especieController = TextEditingController();
  final _variedadController = TextEditingController();
  final _observacionesController = TextEditingController();

  bool _isSaving = false;
  Predio? _predio;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Predio) {
      _predio = args;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _codigoController.dispose();
    _areaController.dispose();
    _especieController.dispose();
    _variedadController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _saveLote() async {
    if (!_formKey.currentState!.validate() || _predio == null) return;

    setState(() => _isSaving = true);

    try {
      final area = double.parse(_areaController.text.trim().replaceAll(',', '.'));

      final lote = Lote(
        loteId: '',
        predioId: _predio!.predioId,
        productorId: _predio!.productorId,
        nombreLote: _nombreController.text.trim(),
        codigoLote: _codigoController.text.trim().isEmpty
            ? null
            : _codigoController.text.trim(),
        areaHectareas: area,
        especieVegetalActual: _especieController.text.trim(),
        variedadActual: _variedadController.text.trim().isEmpty
            ? null
            : _variedadController.text.trim(),
        estadoLote: 'ACTIVO',
        observaciones: _observacionesController.text.trim().isEmpty
            ? null
            : _observacionesController.text.trim(),
        createdAt: null,
        updatedAt: null,
      );

      await _repository.createLote(lote);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lote creado correctamente')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No fue posible crear el lote: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF7F9F5);

    if (_predio == null) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(title: const Text('Crear lote')),
        body: const Center(
          child: Text('No se recibió el predio seleccionado'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Crear lote'),
      ),
      body: LoteForm(
        formKey: _formKey,
        nombreController: _nombreController,
        codigoController: _codigoController,
        areaController: _areaController,
        especieController: _especieController,
        variedadController: _variedadController,
        observacionesController: _observacionesController,
        isSaving: _isSaving,
        onSubmit: _saveLote,
        submitLabel: 'Guardar lote',
      ),
    );
  }
}