import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_tokens.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../domain/expense.dart';
import 'expense_providers.dart';
import 'expense_widgets.dart';

class ExpenseHistoryScreen extends ConsumerWidget {
  const ExpenseHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesValue = ref.watch(expenseControllerProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final query = ref.watch(searchQueryProvider).toLowerCase().trim();

    return AppScaffold(
      title: 'History',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              onChanged: ref.read(searchQueryProvider.notifier).update,
              decoration: const InputDecoration(
                hintText: 'Search merchant or title',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: selectedCategory == null,
                    onSelected: (_) => ref
                        .read(selectedCategoryProvider.notifier)
                        .select(null),
                  ),
                ),
                for (final category in ExpenseCategory.values)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: ChoiceChip(
                      label: Text(category.label),
                      selected: selectedCategory == category,
                      onSelected: (_) => ref
                          .read(selectedCategoryProvider.notifier)
                          .select(category),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: expensesValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(child: Text('$error')),
              data: (allExpenses) {
                final expenses = allExpenses.where((expense) {
                  final matchesCategory =
                      selectedCategory == null ||
                      expense.category == selectedCategory;
                  final matchesQuery =
                      query.isEmpty ||
                      expense.title.toLowerCase().contains(query) ||
                      (expense.merchant ?? '').toLowerCase().contains(query);
                  return matchesCategory && matchesQuery;
                }).toList();
                if (expenses.isEmpty) {
                  return const Center(child: Text('No matching expenses.'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: expenses.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) =>
                      ExpenseTile(expense: expenses[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
