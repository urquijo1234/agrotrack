import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/services/sqlite_service.dart';
import '../../domain/models/evento_agricola.dart';
import '../services/eventos_firebase_service.dart';

class EventosRepository {
  final EventosFirebaseService _firebaseService;
  final SqliteService _sqliteService;
  final Uuid _uuid = const Uuid(); // Generador de IDs locales

  EventosRepository({
    EventosFirebaseService? firebaseService,
    SqliteService? sqliteService,
  })  : _firebaseService = firebaseService ?? EventosFirebaseService(),
        _sqliteService = sqliteService ?? SqliteService();

  // ==========================================
  // 1. CREAR EVENTO (Guardado híbrido)
  // ==========================================
// ==========================================
  // 1. CREAR EVENTO (Guardado híbrido)
  // ==========================================
  Future<void> createEvento(EventoAgricola evento) async {
    final db = await _sqliteService.database;

    // 1. Generar ID local
    final String id = evento.eventoId.isEmpty ? _uuid.v4() : evento.eventoId;
    
    // 2. Preparar el evento
    final eventoLocal = EventoAgricola(
      eventoId: id,
      loteId: evento.loteId,
      predioId: evento.predioId,
      productorId: evento.productorId,
      tipoEvento: evento.tipoEvento,
      fechaEvento: evento.fechaEvento,
      descripcion: evento.descripcion,
      detalleEvento: evento.detalleEvento,
      isSynced: false, 
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // 3. Guardar en SQLite (A esto SÍ lo esperamos porque es ultrarrápido)
    await db.insert(
      'eventos_locales',
      eventoLocal.toSqliteMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // 4. Disparar a Firebase en un hilo completamente separado (Fire-and-forget)
    // NOTA: No tiene 'await', por lo que Dart sigue a la siguiente línea al instante.
    _intentarSubidaSilenciosa(eventoLocal, db);

    // 5. ¡Fin del método! La UI recibe la señal de éxito inmediatamente.
    return;
  }

  // Función privada que se queda trabajando en el fondo
  Future<void> _intentarSubidaSilenciosa(EventoAgricola evento, Database db) async {
    try {
      // Firebase intentará subirlo. Si no hay red, este await se quedará 
      // esperando silenciosamente sin afectar la pantalla del usuario.
      await _firebaseService.pushEvento(evento);
      
      // Si llega aquí, es porque logró subirlo a la nube.
      await db.update(
        'eventos_locales',
        {'isSynced': 1, 'updatedAt': DateTime.now().toIso8601String()},
        where: 'eventoId = ?',
        whereArgs: [evento.eventoId],
      );
      print('Éxito: Evento subido y marcado como sincronizado.');
    } catch (e) {
      // El error de DNS (UnknownHostException) caerá aquí si la petición caduca.
      print('Firebase no pudo subir el evento en este momento. Queda pendiente en SQLite.');
    }
  }
  // ==========================================
  // 2. LEER EVENTOS (Lectura offline garantizada)
  // ==========================================
  Future<List<EventoAgricola>> getEventosByLote(String loteId) async {
    final db = await _sqliteService.database;
    
    // Siempre leemos de la base de datos local para que cargue instantáneo,
    // haya internet o no.
    final List<Map<String, dynamic>> maps = await db.query(
      'eventos_locales',
      where: 'loteId = ?',
      whereArgs: [loteId],
      orderBy: 'fechaEvento DESC',
    );

   return maps.map((map) => EventoAgricola.fromSqliteMap(map)).toList();
  }


  // NUEVO: Obtener la cola de eventos pendientes de sincronizar
  Future<List<EventoAgricola>> getPendingEvents() async {
    final db = await _sqliteService.database;
    final maps = await db.query(
      'eventos_locales',
      where: 'isSynced = ?',
      whereArgs: [0], // 0 significa 'false' en SQLite
    );
    return maps.map((map) => EventoAgricola.fromSqliteMap(map)).toList();
  }
  // ==========================================
  // 3. SINCRONIZACIÓN DIFERIDA (Push de cola)
  // ==========================================
  Future<void> syncPendingEvents() async {
    final db = await _sqliteService.database;
    
    // Buscar todos los eventos que no se han subido
    final List<Map<String, dynamic>> pendingMaps = await db.query(
      'eventos_locales',
      where: 'isSynced = ?',
      whereArgs: [0],
    );

    for (var map in pendingMaps) {
      final evento = EventoAgricola.fromSqliteMap(map);
      try {
        await _firebaseService.pushEvento(evento);
        
        // Actualizar estado a sincronizado
        await db.update(
          'eventos_locales',
          {'isSynced': 1, 'updatedAt': DateTime.now().toIso8601String()},
          where: 'eventoId = ?',
          whereArgs: [evento.eventoId],
        );
      } catch (e) {
        print('Fallo al sincronizar el evento ${evento.eventoId}: $e');
        // Si falla uno por un error de conexión, continuamos con el siguiente
        // o abortamos. Por ahora, seguimos intentando.
      }
    }
  }

  // ==========================================
  // 4. UTILIDAD PARA LA UI
  // ==========================================
  
  /// Útil para poner un indicador en el Dashboard ("Tienes 3 eventos por sincronizar")
  Future<int> getPendingSyncCount() async {
     final db = await _sqliteService.database;
     final count = Sqflite.firstIntValue(
       await db.rawQuery('SELECT COUNT(*) FROM eventos_locales WHERE isSynced = 0')
     );
     return count ?? 0;
  }


  // ==========================================
  // 5. HIDRATAR SQLITE (Remote -> Local)
  // ==========================================
  Future<void> downloadEventosToLocal(String loteId, String productorId) async {
    try {
      // 1. Traemos los datos de Firebase (Ahora enviando el productorId)
      final eventosFirebase = await _firebaseService.getEventosFromFirebase(loteId, productorId);
      final db = await _sqliteService.database;

      // 2. Los guardamos en SQLite
      for (var evento in eventosFirebase) {
        await db.insert(
          'eventos_locales',
          evento.toSqliteMap(),
          conflictAlgorithm: ConflictAlgorithm.replace, 
        );
      }
    } catch (e) {
      print('No se pudieron descargar los eventos de Firebase: $e');
    }
  }


}