import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:snap_bill/app/app.dart';
import 'package:snap_bill/core/database/app_settings_store.dart';
import 'package:snap_bill/features/expenses/domain/expense.dart';
import 'package:snap_bill/features/expenses/domain/expense_repository.dart';
import 'package:snap_bill/features/expenses/presentation/expense_providers.dart';

class FakeExpenseRepository implements ExpenseRepository {
  FakeExpenseRepository(this._expenses);

  final List<Expense> _expenses;

  @override
  Future<void> addExpense(Expense expense) async => _expenses.add(expense);

  @override
  Future<void> deleteExpense(String id) async =>
      _expenses.removeWhere((expense) => expense.id == id);

  @override
  Future<List<Expense>> fetchExpenses() async => _expenses;

  @override
  Future<Expense?> findById(String id) async {
    for (final expense in _expenses) {
      if (expense.id == id) return expense;
    }
    return null;
  }

  @override
  Future<void> resetDemoData() async {}

  @override
  Future<void> seedIfEmpty() async {}
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('dashboard renders empty monthly state', (tester) async {
    await const AppSettingsStore().setBool('onboarding_completed', true);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          expenseRepositoryProvider.overrideWithValue(
            FakeExpenseRepository([]),
          ),
        ],
        child: const SnapBillApp(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();
    expect(find.text('SnapBill'), findsOneWidget);
    expect(find.text('Total spent this month'), findsOneWidget);
    expect(find.text('0 transactions tracked offline'), findsOneWidget);
  });
}
