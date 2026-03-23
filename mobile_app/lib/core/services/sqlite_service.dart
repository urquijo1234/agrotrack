import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqliteService {
  // Patrón Singleton para mantener una única conexión abierta
  static final SqliteService _instance = SqliteService._internal();
  factory SqliteService() => _instance;
  SqliteService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'agrotrack_local.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Creación de la tabla para eventos agrícolas
    await db.execute('''
      CREATE TABLE eventos_locales (
        eventoId TEXT PRIMARY KEY,
        loteId TEXT NOT NULL,
        predioId TEXT NOT NULL,
        productorId TEXT NOT NULL,
        tipoEvento TEXT NOT NULL,
        fechaEvento TEXT NOT NULL,
        descripcion TEXT,
        detalleEvento TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
    
    // Índices para agilizar las lecturas por lote y por sincronización pendiente
    await db.execute('CREATE INDEX idx_loteId ON eventos_locales(loteId)');
    await db.execute('CREATE INDEX idx_isSynced ON eventos_locales(isSynced)');
  }

  // Método de utilidad para limpiar la base de datos (ej: al cerrar sesión)
  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('eventos_locales');
  }
}