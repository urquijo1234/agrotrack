import 'package:flutter/material.dart';
import '../../data/repositories/predios_repository.dart';
import '../../domain/models/predio.dart';
import '../widgets/predio_form.dart';

class PredioEditPage extends StatefulWidget {
  const PredioEditPage({super.key});

  @override
  State<PredioEditPage> createState() => _PredioEditPageState();
}

class _PredioEditPageState extends State<PredioEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _repository = PrediosRepository();

  final _nombreController = TextEditingController();
  final _departamentoController = TextEditingController();
  final _municipioController = TextEditingController();
  final _veredaController = TextEditingController();
  final _areaController = TextEditingController();
  final _numeroIcaController = TextEditingController();

  bool _isSaving = false;
  bool _isLoading = true;
  Predio? _predio;

  @override
  void dispose() {
    _nombreController.dispose();
    _departamentoController.dispose();
    _municipioController.dispose();
    _veredaController.dispose();
    _areaController.dispose();
    _numeroIcaController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_predio == null && _isLoading) {
      _loadPredio();
    }
  }

  Future<void> _loadPredio() async {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is! Predio) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se recibió el predio a editar')),
      );
      Navigator.pop(context);
      return;
    }

    try {
      final predio = await _repository.getPredioById(args.predioId);

      if (predio == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Predio no encontrado')),
        );
        Navigator.pop(context);
        return;
      }

      _predio = predio;
      _nombreController.text = predio.nombrePredio;
      _departamentoController.text = predio.departamento;
      _municipioController.text = predio.municipio;
      _veredaController.text = predio.vereda ?? '';
      _areaController.text =
          predio.areaRegistradaHa != null ? '${predio.areaRegistradaHa}' : '';
      _numeroIcaController.text = predio.numeroRegistroICA ?? '';
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar predio: $e')),
      );
      Navigator.pop(context);
      return;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updatePredio() async {
    if (!_formKey.currentState!.validate() || _predio == null) return;

    setState(() => _isSaving = true);

    try {
      final areaText = _areaController.text.trim();
      final area = areaText.isEmpty
          ? null
          : double.tryParse(areaText.replaceAll(',', '.'));

      final updatedPredio = Predio(
        predioId: _predio!.predioId,
        productorId: _predio!.productorId,
        nombrePredio: _nombreController.text.trim(),
        departamento: _departamentoController.text.trim(),
        municipio: _municipioController.text.trim(),
        vereda: _veredaController.text.trim().isEmpty
            ? null
            : _veredaController.text.trim(),
        numeroRegistroICA: _numeroIcaController.text.trim().isEmpty
            ? null
            : _numeroIcaController.text.trim(),
        areaRegistradaHa: area,
        estadoPredio: _predio!.estadoPredio,
        createdAt: _predio!.createdAt,
        updatedAt: _predio!.updatedAt,
      );

      await _repository.updatePredio(updatedPredio);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Predio actualizado correctamente')),
      );

      Navigator.pop(context, updatedPredio);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No fue posible actualizar el predio: $e')),
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
        title: const Text('Editar predio'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : PredioForm(
              formKey: _formKey,
              nombreController: _nombreController,
              departamentoController: _departamentoController,
              municipioController: _municipioController,
              veredaController: _veredaController,
              areaController: _areaController,
              numeroIcaController: _numeroIcaController,
              isSaving: _isSaving,
              onSubmit: _updatePredio,
              submitLabel: 'Guardar cambios',
            ),
    );
  }
}