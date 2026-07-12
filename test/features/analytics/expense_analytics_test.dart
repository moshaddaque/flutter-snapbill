import 'package:flutter_test/flutter_test.dart';
import 'package:snap_bill/features/analytics/domain/expense_analytics.dart';
import 'package:snap_bill/features/expenses/domain/expense.dart';

void main() {
  final july = DateTime(2026, 7, 1);

  Expense expense({
    required String id,
    required double amount,
    required ExpenseCategory category,
    required DateTime date,
  }) {
    return Expense(
      id: id,
      title: id,
      amount: amount,
      category: category,
      date: date,
    );
  }

  test('filters expenses by selected month', () {
    final expenses = [
      expense(
        id: 'july-food',
        amount: 20,
        category: ExpenseCategory.food,
        date: DateTime(2026, 7, 4),
      ),
      expense(
        id: 'august-food',
        amount: 50,
        category: ExpenseCategory.food,
        date: DateTime(2026, 8, 1),
      ),
    ];

    final result = ExpenseAnalytics.forMonth(expenses, july);

    expect(result, hasLength(1));
    expect(result.single.id, 'july-food');
  });

  test('calculates total and category aggregation', () {
    final expenses = [
      expense(
        id: 'groceries',
        amount: 35,
        category: ExpenseCategory.food,
        date: july,
      ),
      expense(
        id: 'dinner',
        amount: 15,
        category: ExpenseCategory.food,
        date: july,
      ),
      expense(
        id: 'train',
        amount: 10,
        category: ExpenseCategory.transport,
        date: july,
      ),
    ];

    final breakdown = ExpenseAnalytics.categoryBreakdown(expenses);

    expect(ExpenseAnalytics.total(expenses), 60);
    expect(breakdown.first.category, ExpenseCategory.food);
    expect(breakdown.first.total, 50);
    expect(breakdown.first.count, 2);
  });

  test('returns null percentage change when previous month is zero', () {
    expect(
      ExpenseAnalytics.percentageChange(current: 100, previous: 0),
      isNull,
    );
  });

  test('calculates previous month percentage change', () {
    expect(ExpenseAnalytics.percentageChange(current: 125, previous: 100), 25);
  });
}
