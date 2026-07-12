import 'expense.dart';

abstract interface class ExpenseRepository {
  Future<List<Expense>> fetchExpenses();
  Future<Expense?> findById(String id);
  Future<void> addExpense(Expense expense);
  Future<void> deleteExpense(String id);
  Future<void> resetDemoData();
  Future<void> seedIfEmpty();
}
