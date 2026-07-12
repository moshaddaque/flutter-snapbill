import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../domain/expense.dart';
import 'expense_providers.dart';

class ExpenseDetailScreen extends ConsumerWidget {
  const ExpenseDetailScreen({super.key, required this.expenseId});

  final String expenseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseControllerProvider);

    return AppScaffold(
      title: 'Expense details',
      child: expenses.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('$error')),
        data: (items) {
          Expense? expense;
          for (final item in items) {
            if (item.id == expenseId) {
              expense = item;
              break;
            }
          }
          if (expense == null) {
            return const Center(child: Text('Expense not found.'));
          }
          final selectedExpense = expense;
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: expense.category.color.withValues(alpha: .14),
                child: Icon(
                  expense.category.icon,
                  color: expense.category.color,
                  size: 34,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                AppFormatters.currency.format(expense.amount),
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(
                expense.merchant ?? expense.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              _DetailRow(label: 'Category', value: expense.category.label),
              _DetailRow(
                label: 'Date',
                value: AppFormatters.shortDate.format(expense.date),
              ),
              if (expense.note != null)
                _DetailRow(label: 'Note', value: expense.note!),
              if (expense.receiptImagePath != null) ...[
                const SizedBox(height: AppSpacing.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Image.file(
                    File(expense.receiptImagePath!),
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox(
                      height: 120,
                      child: Center(child: Text('Receipt image unavailable')),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton.icon(
                onPressed: () async {
                  final controller = ref.read(
                    expenseControllerProvider.notifier,
                  );
                  await controller.deleteExpense(
                    selectedExpense.id,
                    refresh: false,
                  );
                  if (context.mounted) context.pop();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    controller.reload();
                  });
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete expense'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}
