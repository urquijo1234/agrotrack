import 'package:flutter/material.dart';
import '../../domain/models/lote.dart';

class LoteCard extends StatelessWidget {
  final Lote lote;
  final VoidCallback onTap;

  const LoteCard({
    super.key,
    required this.lote,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const border = Color(0xFFD7DED3);
    const text = Color(0xFF1F2937);
    const softText = Color(0xFF6B7280);
    const softBg = Color(0xFFF4F7F2);
    const primary = Color(0xFF2E7D32);

    final subtitle = lote.variedadActual != null && lote.variedadActual!.trim().isNotEmpty
        ? '${lote.especieVegetalActual} · ${lote.variedadActual}'
        : lote.especieVegetalActual;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lote.nombreLote,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: softText,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: softBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Área: ${lote.areaHectareas} ha',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: text,
                    ),
                  ),
                ),
                Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  decoration: BoxDecoration(
    color: lote.estadoLote == 'ACTIVO'
        ? const Color(0xFFEAF4E7)
        : const Color(0xFFF3F4F6),
    borderRadius: BorderRadius.circular(999),
  ),
  child: Text(
    lote.estadoLote,
    style: TextStyle(
      color: lote.estadoLote == 'ACTIVO'
          ? primary
          : const Color(0xFF6B7280),
      fontWeight: FontWeight.w700,
    ),
  ),
),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Ver lote'),
            ),
          ),
        ],
      ),
    );
  }
}