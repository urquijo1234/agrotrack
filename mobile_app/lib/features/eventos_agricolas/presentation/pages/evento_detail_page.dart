import 'package:flutter/material.dart';
import '../../domain/models/evento_agricola.dart';

class EventoDetailPage extends StatefulWidget {
  const EventoDetailPage({super.key});

  @override
  State<EventoDetailPage> createState() => _EventoDetailPageState();
}

class _EventoDetailPageState extends State<EventoDetailPage> {
  EventoAgricola? _evento;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is EventoAgricola) {
      _evento = args;
    }
  }

  // Traductor de Enum a Título
  String _getTituloEvento(TipoEvento tipo) {
    switch (tipo) {
      case TipoEvento.SIEMBRA:
        return 'Siembra';
      case TipoEvento.APLICACION_INSUMO:
        return 'Aplicación de Insumo';
      case TipoEvento.COSECHA:
        return 'Cosecha';
    }
  }

  // Icono y color según el tipo
  IconData _getIconoEvento(TipoEvento tipo) {
    switch (tipo) {
      case TipoEvento.SIEMBRA: return Icons.grass;
      case TipoEvento.APLICACION_INSUMO: return Icons.science_outlined;
      case TipoEvento.COSECHA: return Icons.shopping_basket_outlined;
    }
  }

  Color _getColorEvento(TipoEvento tipo) {
    switch (tipo) {
      case TipoEvento.SIEMBRA: return Colors.green.shade700;
      case TipoEvento.APLICACION_INSUMO: return Colors.blue.shade700;
      case TipoEvento.COSECHA: return Colors.orange.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF7F9F5);
    const text = Color(0xFF1F2937);

    if (_evento == null) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(title: const Text('Detalle del Evento')),
        body: const Center(child: Text('No se recibió la información del evento')),
      );
    }

    final titulo = _getTituloEvento(_evento!.tipoEvento);
    final icon = _getIconoEvento(_evento!.tipoEvento);
    final color = _getColorEvento(_evento!.tipoEvento);
    final detalle = _evento!.detalleEvento;

    final fechaFormateada = "${_evento!.fechaEvento.day.toString().padLeft(2, '0')}/${_evento!.fechaEvento.month.toString().padLeft(2, '0')}/${_evento!.fechaEvento.year}";

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Detalle del Evento'),
        actions: [
          // Indicador de sincronización en el AppBar
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(
              _evento!.isSynced ? Icons.cloud_done : Icons.cloud_off,
              color: _evento!.isSynced ? Colors.green.shade600 : Colors.grey,
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tarjeta de Cabecera
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Registrado el $fechaFormateada',
                        style: const TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Título de la sección de datos
          const Text(
            'Información Técnica',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: text),
          ),
          const SizedBox(height: 16),

          // Contenedor de datos dinámico
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD7DED3)),
            ),
            child: Column(
              children: _construirDetallesDinamicos(detalle, _evento!.tipoEvento),
            ),
          ),
        ],
      ),
    );
  }

  // Este método extrae los datos del Map y los formatea como filas
  List<Widget> _construirDetallesDinamicos(Map<String, dynamic> detalle, TipoEvento tipo) {
    List<Widget> filas = [];

    // Helper para agregar una fila si el valor existe y no está vacío
    void agregarFila(String label, dynamic value) {
      if (value != null && value.toString().trim().isNotEmpty) {
        filas.add(_InfoRow(label: label, value: value.toString()));
        filas.add(const Divider(height: 1, color: Color(0xFFF3F4F6)));
      }
    }

    // Parseo según el tipo de evento (respetando tu Diccionario de Datos)
    if (tipo == TipoEvento.SIEMBRA) {
      agregarFila('Especie', detalle['especieVegetal']);
      agregarFila('Variedad', detalle['variedad']);
      agregarFila('Cantidad Sembrada', '${detalle['cantidadSembrada']} ${detalle['unidadCantidad']}');
      agregarFila('Área Sembrada', '${detalle['areaSembradaHa']} ha');
      agregarFila('Origen de Semilla', detalle['origenSemilla']);
      agregarFila('Observaciones', detalle['observaciones']);
    } 
    else if (tipo == TipoEvento.APLICACION_INSUMO) {
      agregarFila('Tipo de Insumo', detalle['tipoInsumo']);
      agregarFila('Nombre Comercial', detalle['nombreInsumo']);
      agregarFila('Ingrediente Activo', detalle['ingredienteActivo']);
      agregarFila('Dosis Aplicada', '${detalle['dosis']} ${detalle['unidadDosis']}');
      agregarFila('Método', detalle['metodoAplicacion']);
      agregarFila('Área Tratada', '${detalle['areaTratadaHa']} ha');
      agregarFila('Motivo', detalle['motivoAplicacion']);
      agregarFila('Responsable', detalle['responsableAplicacion']);
      agregarFila('Observaciones', detalle['observaciones']);
    } 
    else if (tipo == TipoEvento.COSECHA) {
      agregarFila('Especie', detalle['especieVegetal']);
      agregarFila('Cantidad Cosechada', '${detalle['cantidadCosechada']} ${detalle['unidadProduccion']}');
      agregarFila('Área Cosechada', '${detalle['areaCosechadaHa']} ha');
      agregarFila('Destino', detalle['destinoProduccion']);
      agregarFila('Responsable', detalle['responsableCosecha']);
      agregarFila('Observaciones', detalle['observaciones']);
    }

    // Quitamos el último Divider para que se vea más limpio
    if (filas.isNotEmpty) {
      filas.removeLast();
    }

    return filas;
  }
}

// Widget auxiliar para mostrar etiqueta y valor
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}