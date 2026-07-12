import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../domain/expense.dart';

class ExpenseTile extends StatelessWidget {
  const ExpenseTile({super.key, required this.expense});

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: expense.category.color.withValues(alpha: .14),
        child: Icon(expense.category.icon, color: expense.category.color),
      ),
      title: Text(expense.merchant ?? expense.title),
      subtitle: Text(
        '${expense.category.label} • ${AppFormatters.shortDate.format(expense.date)}',
      ),
      trailing: Text(
        AppFormatters.currency.format(expense.amount),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      onTap: () => context.push('/expense/${expense.id}'),
    );
  }
}

class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final ExpenseCategory selected;
  final ValueChanged<ExpenseCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final category in ExpenseCategory.values)
          ChoiceChip(
            avatar: Icon(category.icon, size: 18),
            label: Text(category.label),
            selected: selected == category,
            onSelected: (_) => onSelected(category),
          ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}
