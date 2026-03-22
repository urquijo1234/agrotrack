import 'package:flutter/material.dart';

class PrediosEmptyState extends StatelessWidget {
  final VoidCallback onCreate;

  const PrediosEmptyState({super.key, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.landscape, size: 64, color: Colors.grey),
        const SizedBox(height: 16),
        const Text(
          'Aún no tienes predios registrados',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: onCreate,
          child: const Text('Crear predio'),
        ),
      ],
    );
  }
}