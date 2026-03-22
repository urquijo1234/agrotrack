import '../../domain/models/predio.dart';
import '../services/predios_service.dart';

class PrediosRepository {
  final PrediosService _service;

  PrediosRepository({PrediosService? service})
      : _service = service ?? PrediosService();

  Future<List<Predio>> getPrediosByProductor(String productorId) {
    return _service.getPrediosByProductor(productorId);
  }

  Future<void> createPredio(Predio predio) {
    return _service.createPredio(predio);
  }

  Future<Predio?> getPredioById(String predioId) {
    return _service.getPredioById(predioId);
  }

  Future<void> updatePredio(Predio predio) {
    return _service.updatePredio(predio);
  }

  Future<void> updateEstadoPredio({
  required String predioId,
  required String estadoPredio,
}) {
  return _service.updateEstadoPredio(
    predioId: predioId,
    estadoPredio: estadoPredio,
  );
}
}