import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  LocalDatabase._();

  static Database? _database;

  static Future<Database> get instance async {
    final existing = _database;
    if (existing != null) return existing;

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'snap_bill.db');
    late final Database database;
    try {
      database = await _open(path);
    } catch (_) {
      await deleteDatabase(path);
      database = await _open(path);
    }
    _database = database;
    return database;
  }

  static Future<Database> _open(String path) {
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await _createExpensesTable(db);
        await _createSettingsTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createSettingsTable(db);
        }
      },
      onOpen: (db) async {
        await _createExpensesTable(db);
        await _createSettingsTable(db);
      },
    );
  }

  static Future<void> _createExpensesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS expenses(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        receiptImagePath TEXT,
        merchant TEXT
      )
    ''');
  }

  static Future<void> _createSettingsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_settings(
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }
}
