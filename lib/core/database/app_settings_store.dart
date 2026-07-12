import 'package:sqflite/sqflite.dart';

import 'local_database.dart';

class AppSettingsStore {
  const AppSettingsStore();

  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final db = await LocalDatabase.instance;
    final rows = await db.query(
      'app_settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return defaultValue;
    return rows.first['value'] == 'true';
  }

  Future<void> setBool(String key, bool value) async {
    final db = await LocalDatabase.instance;
    await db.insert('app_settings', {
      'key': key,
      'value': value ? 'true' : 'false',
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<bool> hasAnyExpense() async {
    final db = await LocalDatabase.instance;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM expenses'),
    );
    return (count ?? 0) > 0;
  }
}
