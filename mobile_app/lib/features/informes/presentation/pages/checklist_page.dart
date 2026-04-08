import 'package:flutter/material.dart';
import '../../domain/models/checklist_item.dart';
import '../../domain/models/checklist_respuesta.dart';
import '../../domain/models/informe_sanitario.dart';
import '../../data/repositories/informes_repository.dart';

class ChecklistPage extends StatefulWidget {
  const ChecklistPage({super.key});

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  final InformesRepository _repository = InformesRepository();

  String? _informeId;
  InformeFitosanitario? _informe;
  List<ChecklistItem> _catalogo = [];
  Map<int, ChecklistRespuesta> _respuestas = {};
  bool _isLoading = true;
  bool _isSaving = false;
  bool _soloLectura = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && _informeId == null) {
      _informeId = args;
      _cargarDatos();
    }
  }

  Future<void> _cargarDatos() async {
    if (_informeId == null) return;
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _repository.getChecklistCatalogo(),
        _repository.getChecklistRespuestas(_informeId!),
        _repository.getInformeById(_informeId!),
      ]);

      final catalogo = results[0] as List<ChecklistItem>;
      final respuestasLista = results[1] as List<ChecklistRespuesta>;
      final informe = results[2] as InformeFitosanitario?;

      final Map<int, ChecklistRespuesta> mapa = {};

      // Inicializar con respuestas vacías para todos los ítems
      for (final item in catalogo) {
        mapa[item.numeroItem] = ChecklistRespuesta(
          numeroItem: item.numeroItem,
          seccion: item.seccion,
        );
      }

      // Sobrescribir con respuestas guardadas
      for (final r in respuestasLista) {
        mapa[r.numeroItem] = r;
      }

      if (!mounted) return;
      setState(() {
        _catalogo = catalogo;
        _respuestas = mapa;
        _informe = informe;
        _soloLectura = informe?.estadoInforme != EstadoInforme.BORRADOR;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _guardar() async {
    if (_informeId == null || _soloLectura) return;
    setState(() => _isSaving = true);

    try {
      await _repository.guardarChecklistRespuestas(
        informeId: _informeId!,
        respuestas: _respuestas.values.toList(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checklist guardado correctamente')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _updateCumple(int numeroItem, bool? value) {
    setState(() {
      _respuestas[numeroItem] =
          _respuestas[numeroItem]!.copyWith(cumple: value);
    });
  }

  void _updateEstado(int numeroItem, String? value) {
    setState(() {
      _respuestas[numeroItem] =
          _respuestas[numeroItem]!.copyWith(estado: value);
    });
  }

  void _updateSenalizado(int numeroItem, bool? value) {
    setState(() {
      _respuestas[numeroItem] =
          _respuestas[numeroItem]!.copyWith(senalizado: value);
    });
  }

  void _updateObservacion(int numeroItem, String value) {
    setState(() {
      _respuestas[numeroItem] =
          _respuestas[numeroItem]!.copyWith(observacion: value);
    });
  }

  List<ChecklistItem> _getItemsBySeccion(String seccion) {
    return _catalogo.where((item) => item.seccion == seccion).toList();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2E7D32);
    const bg = Color(0xFFF7F9F5);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Checklist ICA'),
        backgroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primary))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              children: [
                if (_soloLectura)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Informe emitido — solo lectura',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                  ),

                _buildSeccionHeader('V', 'Áreas e Instalaciones'),
                ..._getItemsBySeccion('V').map((item) =>
                    _ChecklistItemWidget(
                      item: item,
                      respuesta: _respuestas[item.numeroItem]!,
                      soloLectura: _soloLectura,
                      onCumpleChanged: (v) =>
                          _updateCumple(item.numeroItem, v),
                      onEstadoChanged: (v) =>
                          _updateEstado(item.numeroItem, v),
                      onSenalizadoChanged: (v) =>
                          _updateSenalizado(item.numeroItem, v),
                      onObservacionChanged: (v) =>
                          _updateObservacion(item.numeroItem, v),
                    )),

                const SizedBox(height: 8),
                _buildSeccionHeader(
                    'VI', 'Obligaciones del Titular del Registro'),
                ..._getItemsBySeccion('VI').map((item) =>
                    _ChecklistItemWidget(
                      item: item,
                      respuesta: _respuestas[item.numeroItem]!,
                      soloLectura: _soloLectura,
                      onCumpleChanged: (v) =>
                          _updateCumple(item.numeroItem, v),
                      onEstadoChanged: (v) =>
                          _updateEstado(item.numeroItem, v),
                      onSenalizadoChanged: (v) =>
                          _updateSenalizado(item.numeroItem, v),
                      onObservacionChanged: (v) =>
                          _updateObservacion(item.numeroItem, v),
                    )),

                const SizedBox(height: 8),
                _buildSeccionHeader('VII',
                    'Obligaciones del Titular — Cumplimiento Manual Técnico'),
                ..._getItemsBySeccion('VII').map((item) =>
                    _ChecklistItemWidget(
                      item: item,
                      respuesta: _respuestas[item.numeroItem]!,
                      soloLectura: _soloLectura,
                      onCumpleChanged: (v) =>
                          _updateCumple(item.numeroItem, v),
                      onEstadoChanged: (v) =>
                          _updateEstado(item.numeroItem, v),
                      onSenalizadoChanged: (v) =>
                          _updateSenalizado(item.numeroItem, v),
                      onObservacionChanged: (v) =>
                          _updateObservacion(item.numeroItem, v),
                    )),

                const SizedBox(height: 8),
                _buildSeccionHeader(
                    'INFO', 'Información del Informe Fitosanitario'),
                ..._getItemsBySeccion('INFO').map((item) =>
                    _ChecklistItemWidget(
                      item: item,
                      respuesta: _respuestas[item.numeroItem]!,
                      soloLectura: _soloLectura,
                      onCumpleChanged: (v) =>
                          _updateCumple(item.numeroItem, v),
                      onEstadoChanged: (v) =>
                          _updateEstado(item.numeroItem, v),
                      onSenalizadoChanged: (v) =>
                          _updateSenalizado(item.numeroItem, v),
                      onObservacionChanged: (v) =>
                          _updateObservacion(item.numeroItem, v),
                    )),
              ],
            ),
      bottomNavigationBar: _soloLectura
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              color: Colors.white,
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(
                          color: Colors.white)
                      : const Text(
                          'Guardar checklist',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ),
    );
  }

  Widget _buildSeccionHeader(String codigo, String titulo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              codigo,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistItemWidget extends StatelessWidget {
  final ChecklistItem item;
  final ChecklistRespuesta respuesta;
  final bool soloLectura;
  final ValueChanged<bool?> onCumpleChanged;
  final ValueChanged<String?> onEstadoChanged;
  final ValueChanged<bool?> onSenalizadoChanged;
  final ValueChanged<String> onObservacionChanged;

  const _ChecklistItemWidget({
    required this.item,
    required this.respuesta,
    required this.soloLectura,
    required this.onCumpleChanged,
    required this.onEstadoChanged,
    required this.onSenalizadoChanged,
    required this.onObservacionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD7DED3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF7EE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${item.numeroItem}',
                  style: const TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.enunciado,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1F2937),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // CUMPLE
          if (item.tieneCumple)
            Row(
              children: [
                const Text(
                  'CUMPLE:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(width: 12),
                _RadioOpcion(
                  label: 'Sí',
                  value: true,
                  groupValue: respuesta.cumple,
                  soloLectura: soloLectura,
                  onChanged: onCumpleChanged,
                ),
                const SizedBox(width: 8),
                _RadioOpcion(
                  label: 'No',
                  value: false,
                  groupValue: respuesta.cumple,
                  soloLectura: soloLectura,
                  onChanged: onCumpleChanged,
                ),
              ],
            ),

          // ESTADO (solo sección V)
          if (item.tieneEstado) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'ESTADO:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(width: 12),
                _RadioOpcionString(
                  label: 'B',
                  value: 'B',
                  groupValue: respuesta.estado,
                  soloLectura: soloLectura,
                  onChanged: onEstadoChanged,
                ),
                const SizedBox(width: 8),
                _RadioOpcionString(
                  label: 'M',
                  value: 'M',
                  groupValue: respuesta.estado,
                  soloLectura: soloLectura,
                  onChanged: onEstadoChanged,
                ),
              ],
            ),
          ],

          // SEÑALIZADO (solo sección V)
          if (item.tieneSenalizado) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'SEÑALIZADO:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(width: 12),
                _RadioOpcion(
                  label: 'Sí',
                  value: true,
                  groupValue: respuesta.senalizado,
                  soloLectura: soloLectura,
                  onChanged: onSenalizadoChanged,
                ),
                const SizedBox(width: 8),
                _RadioOpcion(
                  label: 'No',
                  value: false,
                  groupValue: respuesta.senalizado,
                  soloLectura: soloLectura,
                  onChanged: onSenalizadoChanged,
                ),
              ],
            ),
          ],

          // OBSERVACIÓN
          if (item.tieneObservacion) ...[
            const SizedBox(height: 10),
            TextFormField(
              initialValue: respuesta.observacion ?? '',
              readOnly: soloLectura,
              maxLines: 2,
              onChanged: onObservacionChanged,
              decoration: InputDecoration(
                hintText: 'Observación...',
                filled: true,
                fillColor: const Color(0xFFF7F9F5),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Color(0xFFD7DED3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Color(0xFFD7DED3)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RadioOpcion extends StatelessWidget {
  final String label;
  final bool value;
  final bool? groupValue;
  final bool soloLectura;
  final ValueChanged<bool?> onChanged;

  const _RadioOpcion({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.soloLectura,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = groupValue == value;
    return GestureDetector(
      onTap: soloLectura ? null : () => onChanged(value),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF2E7D32)
              : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF6B7280),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _RadioOpcionString extends StatelessWidget {
  final String label;
  final String value;
  final String? groupValue;
  final bool soloLectura;
  final ValueChanged<String?> onChanged;

  const _RadioOpcionString({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.soloLectura,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = groupValue == value;
    return GestureDetector(
      onTap: soloLectura ? null : () => onChanged(value),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF2E7D32)
              : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF6B7280),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}