import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_tokens.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../domain/expense_analytics.dart';
import '../../expenses/presentation/expense_providers.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesValue = ref.watch(expenseControllerProvider);
    final month = ref.watch(selectedMonthProvider);

    return AppScaffold(
      title: 'Analytics',
      actions: [
        IconButton(
          tooltip: 'Previous month',
          onPressed: () => ref.read(selectedMonthProvider.notifier).previous(),
          icon: const Icon(Icons.chevron_left),
        ),
        IconButton(
          tooltip: 'Next month',
          onPressed: () => ref.read(selectedMonthProvider.notifier).next(),
          icon: const Icon(Icons.chevron_right),
        ),
      ],
      child: expensesValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('$error')),
        data: (allExpenses) {
          final expenses = ExpenseAnalytics.forMonth(allExpenses, month);
          final previousExpenses = ExpenseAnalytics.forMonth(
            allExpenses,
            month.previousMonth,
          );
          final total = ExpenseAnalytics.total(expenses);
          final previousTotal = ExpenseAnalytics.total(previousExpenses);
          final change = ExpenseAnalytics.percentageChange(
            current: total,
            previous: previousTotal,
          );
          final breakdown = ExpenseAnalytics.categoryBreakdown(expenses);
          final top = ExpenseAnalytics.highestCategory(expenses);
          final trend = ExpenseAnalytics.weeklyTrend(expenses, month);
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Text(
                AppFormatters.month.format(month),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _Metric(
                    label: 'Monthly total',
                    value: AppFormatters.currency.format(total),
                  ),
                  _Metric(
                    label: 'Month change',
                    value: change == null
                        ? 'No baseline'
                        : '${change.toStringAsFixed(1)}%',
                  ),
                  _Metric(
                    label: 'Average daily',
                    value: AppFormatters.currency.format(
                      ExpenseAnalytics.averageDailySpending(expenses, month),
                    ),
                  ),
                  _Metric(label: 'Transactions', value: '${expenses.length}'),
                  _Metric(
                    label: 'Highest category',
                    value: top?.category.label ?? 'None',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Spending trend',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 180,
                child: BarChart(
                  BarChartData(
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    barGroups: [
                      for (var i = 0; i < trend.length; i++)
                        BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: trend[i],
                              width: 22,
                              color: AppColors.pine,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Category breakdown',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              if (breakdown.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Text('No expenses for this month.'),
                  ),
                )
              else
                ...breakdown.map(
                  (item) => ListTile(
                    leading: Icon(
                      item.category.icon,
                      color: item.category.color,
                    ),
                    title: Text(item.category.label),
                    subtitle: Text('${item.count} transactions'),
                    trailing: Text(AppFormatters.currency.format(item.total)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 164,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
