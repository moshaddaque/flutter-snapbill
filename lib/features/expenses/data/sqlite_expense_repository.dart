import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_settings_store.dart';
import '../../../core/database/local_database.dart';
import 'demo_expenses.dart';
import '../domain/expense.dart';
import '../domain/expense_repository.dart';

class SqliteExpenseRepository implements ExpenseRepository {
  static const _demoSeededKey = 'demo_seeded';
  final _settings = const AppSettingsStore();

  Future<Database> get _db => LocalDatabase.instance;

  @override
  Future<void> addExpense(Expense expense) async {
    final db = await _db;
    await db.insert(
      'expenses',
      _toMap(expense),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteExpense(String id) async {
    final db = await _db;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Expense>> fetchExpenses() async {
    final db = await _db;
    final rows = await db.query('expenses', orderBy: 'date DESC');
    return rows.map(_fromMap).toList();
  }

  @override
  Future<Expense?> findById(String id) async {
    final db = await _db;
    final rows = await db.query('expenses', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return _fromMap(rows.first);
  }

  @override
  Future<void> resetDemoData() async {
    final db = await _db;
    await db.delete('expenses');
    await _settings.setBool(_demoSeededKey, true);
  }

  @override
  Future<void> seedIfEmpty() async {
    final alreadySeeded = await _settings.getBool(_demoSeededKey);
    if (alreadySeeded) return;

    final db = await _db;
    final result = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM expenses'),
    );
    if (result == 0) {
      final batch = db.batch();
      for (final expense in DemoExpenses.seed(DateTime.now())) {
        batch.insert('expenses', _toMap(expense));
      }
      await batch.commit(noResult: true);
    }
    await _settings.setBool(_demoSeededKey, true);
  }

  Map<String, Object?> _toMap(Expense expense) {
    return {
      'id': expense.id,
      'title': expense.title,
      'amount': expense.amount,
      'category': expense.category.name,
      'date': expense.date.toIso8601String(),
      'note': expense.note,
      'receiptImagePath': expense.receiptImagePath,
      'merchant': expense.merchant,
    };
  }

  Expense _fromMap(Map<String, Object?> map) {
    return Expense(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: ExpenseCategory.fromName(map['category'] as String),
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
      receiptImagePath: map['receiptImagePath'] as String?,
      merchant: map['merchant'] as String?,
    );
  }
}
