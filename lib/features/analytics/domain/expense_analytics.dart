import '../../../core/extensions/date_extensions.dart';
import '../../expenses/domain/expense.dart';

class CategoryTotal {
  const CategoryTotal({
    required this.category,
    required this.total,
    required this.count,
  });

  final ExpenseCategory category;
  final double total;
  final int count;
}

class SpendingInsight {
  const SpendingInsight({required this.title, required this.body});

  final String title;
  final String body;
}

class ExpenseAnalytics {
  const ExpenseAnalytics._();

  static List<Expense> forMonth(List<Expense> expenses, DateTime month) {
    return expenses
        .where((expense) => expense.date.isSameMonth(month))
        .toList();
  }

  static double total(List<Expense> expenses) {
    return expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
  }

  static double? percentageChange({
    required double current,
    required double previous,
  }) {
    if (previous == 0) return null;
    return ((current - previous) / previous) * 100;
  }

  static List<CategoryTotal> categoryBreakdown(List<Expense> expenses) {
    final totals = <ExpenseCategory, double>{};
    final counts = <ExpenseCategory, int>{};
    for (final expense in expenses) {
      totals.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
      counts.update(expense.category, (value) => value + 1, ifAbsent: () => 1);
    }

    final breakdown =
        totals.entries
            .map(
              (entry) => CategoryTotal(
                category: entry.key,
                total: entry.value,
                count: counts[entry.key] ?? 0,
              ),
            )
            .toList()
          ..sort((a, b) => b.total.compareTo(a.total));
    return breakdown;
  }

  static CategoryTotal? highestCategory(List<Expense> expenses) {
    final breakdown = categoryBreakdown(expenses);
    return breakdown.isEmpty ? null : breakdown.first;
  }

  static double averageDailySpending(List<Expense> expenses, DateTime month) {
    final daysElapsed = DateTime.now().isSameMonth(month)
        ? DateTime.now().day
        : DateTime(month.year, month.month + 1, 0).day;
    if (daysElapsed == 0) return 0;
    return total(expenses) / daysElapsed;
  }

  static List<double> weeklyTrend(List<Expense> expenses, DateTime month) {
    final buckets = List<double>.filled(5, 0);
    for (final expense in expenses) {
      if (!expense.date.isSameMonth(month)) continue;
      final bucket = ((expense.date.day - 1) / 7).floor().clamp(0, 4);
      buckets[bucket] += expense.amount;
    }
    return buckets;
  }

  static SpendingInsight localInsight({
    required List<Expense> current,
    required List<Expense> previous,
  }) {
    final currentTop = highestCategory(current);
    if (current.isEmpty) {
      return const SpendingInsight(
        title: 'No spending yet',
        body: 'Add an expense to generate local spending insights.',
      );
    }
    if (currentTop == null) {
      return const SpendingInsight(
        title: 'Spending insight',
        body:
            'Your spending is ready for review once categories are available.',
      );
    }

    final previousTotal = total(
      previous
          .where((expense) => expense.category == currentTop.category)
          .toList(),
    );
    final change = percentageChange(
      current: currentTop.total,
      previous: previousTotal,
    );
    final changeText = change == null
        ? 'is your top category this month'
        : '${change.abs().toStringAsFixed(0)}% ${change >= 0 ? 'more' : 'less'} than last month';

    return SpendingInsight(
      title: 'Local spending insight',
      body: '${currentTop.category.label} $changeText.',
    );
  }
}
