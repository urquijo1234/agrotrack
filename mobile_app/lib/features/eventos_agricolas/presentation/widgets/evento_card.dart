import 'package:flutter/material.dart';
import '../../domain/models/evento_agricola.dart';

class EventoCard extends StatelessWidget {
  final EventoAgricola evento;
  final VoidCallback onTap;

  const EventoCard({
    super.key,
    required this.evento,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const border = Color(0xFFD7DED3);
    const text = Color(0xFF1F2937);
    const softText = Color(0xFF6B7280);

    // Configuramos UI dinámica según el tipo de evento
    IconData icon;
    Color iconColor;
    String titulo = evento.tipoEvento.name.replaceAll('_', ' ');
    String subtitulo = '';

    final detalle = evento.detalleEvento;

    switch (evento.tipoEvento) {
      case TipoEvento.SIEMBRA:
        icon = Icons.grass;
        iconColor = Colors.green.shade700;
        final especie = detalle['especieVegetal'] ?? 'Desconocida';
        final cantidad = detalle['cantidadSembrada'] ?? 0;
        final unidad = detalle['unidadCantidad'] ?? '';
        subtitulo = '$especie · $cantidad $unidad';
        break;
      case TipoEvento.APLICACION_INSUMO:
        icon = Icons.science_outlined;
        iconColor = Colors.blue.shade700;
        final tipo = detalle['tipoInsumo'] ?? '';
        final nombre = detalle['nombreInsumo'] ?? '';
        subtitulo = '$tipo: $nombre';
        break;
      case TipoEvento.COSECHA:
        icon = Icons.shopping_basket_outlined;
        iconColor = Colors.orange.shade700;
        final cant = detalle['cantidadCosechada'] ?? 0;
        final uni = detalle['unidadProduccion'] ?? '';
        subtitulo = 'Recolectado: $cant $uni';
        break;
    }

    // Formatear fecha
    final fecha = "${evento.fechaEvento.day.toString().padLeft(2, '0')}/${evento.fechaEvento.month.toString().padLeft(2, '0')}/${evento.fechaEvento.year}";

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: border),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              
              // Textos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitulo,
                      style: const TextStyle(
                        fontSize: 14,
                        color: softText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Fecha y estado de sincronización
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    fecha,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    evento.isSynced ? Icons.cloud_done : Icons.cloud_off,
                    size: 16,
                    color: evento.isSynced ? Colors.green : Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}