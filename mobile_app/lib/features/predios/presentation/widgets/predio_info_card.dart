import 'package:flutter/material.dart';
import '../../domain/models/predio.dart';

class PredioInfoCard extends StatelessWidget {
  final Predio predio;

  const PredioInfoCard({
    super.key,
    required this.predio,
  });

  @override
  Widget build(BuildContext context) {
    const border = Color(0xFFD7DED3);
    const softBg = Color(0xFFF4F7F2);
    const text = Color(0xFF1F2937);
    const softText = Color(0xFF6B7280);

    String ubicacion = predio.vereda != null && predio.vereda!.trim().isNotEmpty
        ? '${predio.municipio}, ${predio.departamento} · ${predio.vereda}'
        : '${predio.municipio}, ${predio.departamento}';

    return Container(
      width: double.infinity,
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
            predio.nombrePredio,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            ubicacion,
            style: const TextStyle(
              fontSize: 14,
              color: softText,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: predio.estadoPredio == 'ACTIVO'
                  ? const Color(0xFFEAF4E7)
                  : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              predio.estadoPredio,
              style: TextStyle(
                color: predio.estadoPredio == 'ACTIVO'
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFF6B7280),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
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
                  value: predio.numeroRegistroICA?.trim().isNotEmpty == true
                      ? predio.numeroRegistroICA!
                      : '-',
                ),
              ),
            ],
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
    const softBg = Color(0xFFF4F7F2);
    const text = Color(0xFF1F2937);
    const softText = Color(0xFF6B7280);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: softBg,
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
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: text,
            ),
          ),
        ],
      ),
    );
  }
}