import 'package:flutter/material.dart';

class LoteForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nombreController;
  final TextEditingController codigoController;
  final TextEditingController areaController;
  final TextEditingController especieController;
  final TextEditingController variedadController;
  final TextEditingController observacionesController;
  final bool isSaving;
  final VoidCallback onSubmit;
  final String submitLabel;

  const LoteForm({
    super.key,
    required this.formKey,
    required this.nombreController,
    required this.codigoController,
    required this.areaController,
    required this.especieController,
    required this.variedadController,
    required this.observacionesController,
    required this.isSaving,
    required this.onSubmit,
    required this.submitLabel,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2E7D32);
    const bg = Color(0xFFF7F9F5);
    const cardBorder = Color(0xFFD7DED3);
    const fieldBorder = Color(0xFFD6DDD2);
    const titleColor = Color(0xFF1F2937);
    const subtitleColor = Color(0xFF6B7280);

    InputDecoration inputDecoration(String label) {
      return InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: titleColor,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: fieldBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.4),
        ),
      );
    }

    Widget sectionCard({
      required String title,
      required Widget child,
    }) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      );
    }

    return Container(
      color: bg,
      child: SafeArea(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F7F2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: cardBorder),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF4E7),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              '2',
                              style: TextStyle(
                                color: primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Crear lote',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: titleColor,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Registra una unidad trazable dentro del predio seleccionado.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: subtitleColor,
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    sectionCard(
                      title: 'Datos del lote',
                      child: Column(
                        children: [
                          TextFormField(
                            controller: nombreController,
                            decoration: inputDecoration('Nombre del lote'),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'El nombre del lote es obligatorio';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: codigoController,
                            decoration: inputDecoration('Código interno (opcional)'),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: areaController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: inputDecoration('Área (ha)'),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'El área es obligatoria';
                              }
                              final parsed = double.tryParse(
                                value.trim().replaceAll(',', '.'),
                              );
                              if (parsed == null || parsed <= 0) {
                                return 'Ingresa un área válida';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: especieController,
                            decoration: inputDecoration('Especie vegetal actual'),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'La especie vegetal es obligatoria';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: variedadController,
                            decoration: inputDecoration('Variedad actual (opcional)'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    sectionCard(
                      title: 'Notas',
                      child: TextFormField(
                        controller: observacionesController,
                        maxLines: 4,
                        decoration: inputDecoration('Observaciones (opcional)'),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                color: bg,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isSaving
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(54),
                          side: const BorderSide(color: cardBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          foregroundColor: primary,
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : onSubmit,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(54),
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(submitLabel),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}