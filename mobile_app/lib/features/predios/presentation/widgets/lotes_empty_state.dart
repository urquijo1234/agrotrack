import 'package:flutter/material.dart';

class LotesEmptyState extends StatelessWidget {
  final VoidCallback onCreateLote;

  const LotesEmptyState({
    super.key,
    required this.onCreateLote,
  });

  @override
  Widget build(BuildContext context) {
    const border = Color(0xFFD7DED3);
    const text = Color(0xFF1F2937);
    const softText = Color(0xFF6B7280);
    const primary = Color(0xFF2E7D32);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.grid_view_rounded,
            size: 42,
            color: softText,
          ),
          const SizedBox(height: 12),
          const Text(
            'Aún no hay lotes registrados',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: text,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Crea el primer lote dentro de este predio para empezar a organizar la trazabilidad.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: softText,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: onCreateLote,
              icon: const Icon(Icons.add),
              label: const Text('Crear lote'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}