import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/date_extensions.dart';
import '../../analytics/domain/expense_analytics.dart';
import '../data/sqlite_expense_repository.dart';
import '../domain/expense.dart';
import '../domain/expense_repository.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return SqliteExpenseRepository();
});

final expenseControllerProvider =
    AsyncNotifierProvider<ExpenseController, List<Expense>>(
      ExpenseController.new,
    );

class ExpenseController extends AsyncNotifier<List<Expense>> {
  ExpenseRepository get _repository => ref.read(expenseRepositoryProvider);

  @override
  Future<List<Expense>> build() async {
    await _repository.seedIfEmpty();
    return _repository.fetchExpenses();
  }

  Future<void> addExpense(Expense expense, {bool refresh = true}) async {
    await _repository.addExpense(expense);
    if (refresh) await reload();
  }

  Future<void> deleteExpense(String id, {bool refresh = true}) async {
    await _repository.deleteExpense(id);
    if (refresh) await reload();
  }

  Future<void> resetDemoData() async {
    await _repository.resetDemoData();
    await reload();
  }

  Future<void> reload() async {
    state = AsyncData(await _repository.fetchExpenses());
  }
}

final selectedMonthProvider = NotifierProvider<SelectedMonthNotifier, DateTime>(
  SelectedMonthNotifier.new,
);

class SelectedMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now().monthStart;

  void previous() => state = state.previousMonth;

  void next() => state = DateTime(state.year, state.month + 1);
}

final selectedCategoryProvider =
    NotifierProvider<CategoryFilterNotifier, ExpenseCategory?>(
      CategoryFilterNotifier.new,
    );

class CategoryFilterNotifier extends Notifier<ExpenseCategory?> {
  @override
  ExpenseCategory? build() => null;

  void select(ExpenseCategory? category) => state = category;
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String value) => state = value;
}

final filteredExpensesProvider = Provider<AsyncValue<List<Expense>>>((ref) {
  final expenses = ref.watch(expenseControllerProvider);
  final category = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();

  return expenses.whenData((items) {
    return items.where((expense) {
      final matchesCategory = category == null || expense.category == category;
      final matchesQuery =
          query.isEmpty ||
          expense.title.toLowerCase().contains(query) ||
          (expense.merchant ?? '').toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  });
});

final monthlyExpensesProvider = Provider<AsyncValue<List<Expense>>>((ref) {
  final expenses = ref.watch(expenseControllerProvider);
  final month = ref.watch(selectedMonthProvider);
  return expenses.whenData((items) => ExpenseAnalytics.forMonth(items, month));
});

final previousMonthExpensesProvider = Provider<AsyncValue<List<Expense>>>((
  ref,
) {
  final expenses = ref.watch(expenseControllerProvider);
  final month = ref.watch(selectedMonthProvider).previousMonth;
  return expenses.whenData((items) => ExpenseAnalytics.forMonth(items, month));
});

final monthlyTotalProvider = Provider<AsyncValue<double>>((ref) {
  return ref.watch(monthlyExpensesProvider).whenData(ExpenseAnalytics.total);
});

final categoryBreakdownProvider = Provider<AsyncValue<List<CategoryTotal>>>((
  ref,
) {
  return ref
      .watch(monthlyExpensesProvider)
      .whenData(ExpenseAnalytics.categoryBreakdown);
});

final spendingInsightProvider = Provider<AsyncValue<SpendingInsight>>((ref) {
  final current = ref.watch(monthlyExpensesProvider);
  final previous = ref.watch(previousMonthExpensesProvider);
  return current.when(
    loading: AsyncValue.loading,
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
    data: (currentItems) => previous.when(
      loading: AsyncValue.loading,
      error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
      data: (previousItems) => AsyncData(
        ExpenseAnalytics.localInsight(
          current: currentItems,
          previous: previousItems,
        ),
      ),
    ),
  );
});
