import 'package:flutter/material.dart';
import '../../data/repositories/lotes_repository.dart';
import '../../domain/models/lote.dart';
import '../widgets/lote_form.dart';

class LoteEditPage extends StatefulWidget {
  const LoteEditPage({super.key});

  @override
  State<LoteEditPage> createState() => _LoteEditPageState();
}

class _LoteEditPageState extends State<LoteEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _repository = LotesRepository();

  final _nombreController = TextEditingController();
  final _codigoController = TextEditingController();
  final _areaController = TextEditingController();
  final _especieController = TextEditingController();
  final _variedadController = TextEditingController();
  final _observacionesController = TextEditingController();

  bool _isSaving = false;
  bool _isLoading = true;
  Lote? _lote;

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_lote == null && _isLoading) {
      _loadLote();
    }
  }

  Future<void> _loadLote() async {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is! Lote) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se recibió el lote a editar')),
      );
      Navigator.pop(context);
      return;
    }

    try {
      final lote = await _repository.getLoteById(args.loteId);

      if (lote == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lote no encontrado')),
        );
        Navigator.pop(context);
        return;
      }

      _lote = lote;
      _nombreController.text = lote.nombreLote;
      _codigoController.text = lote.codigoLote ?? '';
      _areaController.text = '${lote.areaHectareas}';
      _especieController.text = lote.especieVegetalActual;
      _variedadController.text = lote.variedadActual ?? '';
      _observacionesController.text = lote.observaciones ?? '';
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar lote: $e')),
      );
      Navigator.pop(context);
      return;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateLote() async {
    if (!_formKey.currentState!.validate() || _lote == null) return;

    setState(() => _isSaving = true);

    try {
      final area = double.parse(_areaController.text.trim().replaceAll(',', '.'));

      final updatedLote = Lote(
        loteId: _lote!.loteId,
        predioId: _lote!.predioId,
        productorId: _lote!.productorId,
        nombreLote: _nombreController.text.trim(),
        codigoLote: _codigoController.text.trim().isEmpty
            ? null
            : _codigoController.text.trim(),
        areaHectareas: area,
        especieVegetalActual: _especieController.text.trim(),
        variedadActual: _variedadController.text.trim().isEmpty
            ? null
            : _variedadController.text.trim(),
        estadoLote: _lote!.estadoLote,
        observaciones: _observacionesController.text.trim().isEmpty
            ? null
            : _observacionesController.text.trim(),
        createdAt: _lote!.createdAt,
        updatedAt: _lote!.updatedAt,
      );

      await _repository.updateLote(updatedLote);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lote actualizado correctamente')),
      );

      Navigator.pop(context, updatedLote);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No fue posible actualizar el lote: $e')),
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

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Editar lote'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LoteForm(
              formKey: _formKey,
              nombreController: _nombreController,
              codigoController: _codigoController,
              areaController: _areaController,
              especieController: _especieController,
              variedadController: _variedadController,
              observacionesController: _observacionesController,
              isSaving: _isSaving,
              onSubmit: _updateLote,
              submitLabel: 'Guardar cambios',
            ),
    );
  }
}