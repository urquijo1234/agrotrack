import 'package:flutter/material.dart';
import '../../../lotes/domain/models/lote.dart';

class SeleccionarEventoPage extends StatelessWidget {
  const SeleccionarEventoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final lote = ModalRoute.of(context)?.settings.arguments as Lote?;

    if (lote == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('No se recibió el lote')),
      );
    }

    const bg = Color(0xFFF7F9F5);
    const softText = Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Registrar evento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lote: ${lote.nombreLote}',
              style: const TextStyle(fontSize: 16, color: softText, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              '¿Qué actividad deseas registrar?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 24),
            _OpcionEventoCard(
              title: 'Siembra',
              description: 'Registrar establecimiento de cultivo, área y cantidad de semilla.',
              icon: Icons.grass,
              color: Colors.green.shade700,
              onTap: () => Navigator.pushNamed(context, '/eventos/crear_siembra', arguments: lote),
            ),
            const SizedBox(height: 16),
            _OpcionEventoCard(
              title: 'Aplicación de Insumos',
              description: 'Registrar fertilizantes, herbicidas o fungicidas aplicados.',
              icon: Icons.science_outlined,
              color: Colors.blue.shade700,
             // En _OpcionEventoCard de Insumos:
onTap: () => Navigator.pushNamed(context, '/eventos/crear_insumo', arguments: lote),
            ),
            const SizedBox(height: 16),
            _OpcionEventoCard(
              title: 'Cosecha',
              description: 'Registrar recolección y cantidad producida.',
              icon: Icons.shopping_basket_outlined,
              color: Colors.orange.shade700,
              // En _OpcionEventoCard de Cosecha:
onTap: () => Navigator.pushNamed(context, '/eventos/crear_cosecha', arguments: lote),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpcionEventoCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _OpcionEventoCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD7DED3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.3),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}