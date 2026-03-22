import 'package:flutter/material.dart';
import '../../domain/models/predio.dart';

class PredioCard extends StatelessWidget {
  final Predio predio;
  final VoidCallback onTap;

  const PredioCard({
    super.key,
    required this.predio,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2E7D32);
    const border = Color(0xFFD7DED3);
    const softBg = Color(0xFFF4F7F2);
    const text = Color(0xFF1F2937);
    const softText = Color(0xFF6B7280);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Nombre
          Text(
            predio.nombrePredio,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: text,
            ),
          ),

          const SizedBox(height: 6),

          /// Ubicación
          Text(
            '${predio.municipio}${predio.vereda != null ? " · ${predio.vereda}" : ""}',
            style: const TextStyle(
              fontSize: 14,
              color: softText,
            ),
          ),

          const SizedBox(height: 14),

          /// Datos productivos
          Row(
            children: [
              Expanded(
                child: _InfoBox(
                  label: 'Área total',
                  value: predio.areaRegistradaHa != null
                      ? '${predio.areaRegistradaHa} ha'
                      : '-',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoBox(
                  label: 'Registro ICA',
                  value: predio.numeroRegistroICA ?? '-',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// Acción principal
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
              child: const Text('Ver predio'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String label;
  final String value;

  const _InfoBox({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF4F7F2);
    const text = Color(0xFF1F2937);
    const softText = Color(0xFF6B7280);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: softText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: text,
            ),
          ),
        ],
      ),
    );
  }
}