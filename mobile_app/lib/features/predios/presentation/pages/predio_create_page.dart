import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../data/repositories/predios_repository.dart';
import '../../domain/models/predio.dart';
import '../widgets/predio_form.dart';

class PredioCreatePage extends StatefulWidget {
  const PredioCreatePage({super.key});

  @override
  State<PredioCreatePage> createState() => _PredioCreatePageState();
}

class _PredioCreatePageState extends State<PredioCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _repository = PrediosRepository();

  final _nombreController = TextEditingController();
  final _departamentoController = TextEditingController();
  final _municipioController = TextEditingController();
  final _veredaController = TextEditingController();
  final _areaController = TextEditingController();
  final _numeroIcaController = TextEditingController();

  bool _isSaving = false;

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

  Future<void> _savePredio() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay usuario autenticado')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final areaText = _areaController.text.trim();
      final area = areaText.isEmpty
          ? null
          : double.tryParse(areaText.replaceAll(',', '.'));

      final predio = Predio(
        predioId: '',
        productorId: user.uid,
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
        estadoPredio: 'ACTIVO',
        createdAt: null,
        updatedAt: null,
      );

      await _repository.createPredio(predio);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Predio creado correctamente')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No fue posible crear el predio: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear predio'),
      ),
      body: PredioForm(
        formKey: _formKey,
        nombreController: _nombreController,
        departamentoController: _departamentoController,
        municipioController: _municipioController,
        veredaController: _veredaController,
        areaController: _areaController,
        numeroIcaController: _numeroIcaController,
        isSaving: _isSaving,
        onSubmit: _savePredio,
        submitLabel: 'Guardar predio',
      ),
    );
  }
}