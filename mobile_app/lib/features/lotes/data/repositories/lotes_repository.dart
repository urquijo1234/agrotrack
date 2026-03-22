import '../../domain/models/lote.dart';
import '../services/lotes_service.dart';

class LotesRepository {
  final LotesService _service;

  LotesRepository({LotesService? service})
      : _service = service ?? LotesService();

  Future<void> createLote(Lote lote) {
    return _service.createLote(lote);
  }

  Future<List<Lote>> getLotesByPredio({
    required String predioId,
    required String productorId,
  }) {
    return _service.getLotesByPredio(
      predioId: predioId,
      productorId: productorId,
    );
  }

  Future<Lote?> getLoteById(String loteId) {
    return _service.getLoteById(loteId);
  }

  Future<void> updateLote(Lote lote) {
    return _service.updateLote(lote);
  }


  Future<void> updateEstadoLote({
  required String loteId,
  required String estadoLote,
}) {
  return _service.updateEstadoLote(
    loteId: loteId,
    estadoLote: estadoLote,
  );
}
}