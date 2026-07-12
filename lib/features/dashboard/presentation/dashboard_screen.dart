import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_tokens.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../analytics/domain/expense_analytics.dart';
import '../../expenses/domain/expense.dart';
import '../../expenses/presentation/expense_providers.dart';
import '../../expenses/presentation/expense_widgets.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesValue = ref.watch(expenseControllerProvider);
    final month = ref.watch(selectedMonthProvider);

    return AppScaffold(
      title: 'SnapBill',
      actions: [
        IconButton(
          tooltip: 'Notifications',
          onPressed: () {},
          icon: const Icon(Icons.notifications_none),
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
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
          final trend = ExpenseAnalytics.weeklyTrend(expenses, month);
          final recent = expenses.take(4).toList();
          final insight = ExpenseAnalytics.localInsight(
            current: expenses,
            previous: previousExpenses,
          );
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _Header(month: month),
              const SizedBox(height: AppSpacing.md),
              _SpendingCard(total: total, expenses: expenses, trend: trend),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.add_card,
                      label: 'Add Expense',
                      onTap: () => context.push('/add'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.document_scanner_outlined,
                      label: 'Attach Receipt',
                      onTap: () => context.push('/receipt'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(title: 'Categories'),
              const SizedBox(height: AppSpacing.sm),
              _CategoryOverview(expenses: expenses),
              const SizedBox(height: AppSpacing.lg),
              _InsightCard(insight: insight),
              const SizedBox(height: AppSpacing.lg),
              SectionHeader(
                title: 'Recent transactions',
                actionLabel: 'View all',
                onAction: () => context.push('/history'),
              ),
              if (recent.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: Text('No expenses this month yet.')),
                )
              else
                ...recent.map((expense) => ExpenseTile(expense: expense)),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.month});

  final DateTime month;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good to see you',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                AppFormatters.month.format(month),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const CircleAvatar(child: Icon(Icons.person_outline)),
      ],
    );
  }
}

class _SpendingCard extends StatelessWidget {
  const _SpendingCard({
    required this.total,
    required this.expenses,
    required this.trend,
  });

  final double total;
  final List<Expense> expenses;
  final List<double> trend;

  @override
  Widget build(BuildContext context) {
    final maxY = trend.fold<double>(
      0,
      (max, value) => value > max ? value : max,
    );
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        gradient: const LinearGradient(
          colors: [AppColors.pine, Color(0xFF103B43)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total spent this month',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            AppFormatters.currency.format(total),
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${expenses.length} transactions tracked offline',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 76,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY == 0 ? 100 : maxY * 1.2,
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (var i = 0; i < trend.length; i++)
                        FlSpot(i.toDouble(), trend[i]),
                    ],
                    isCurved: true,
                    color: AppColors.mint,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.mint.withValues(alpha: .18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
    );
  }
}

class _CategoryOverview extends StatelessWidget {
  const _CategoryOverview({required this.expenses});

  final List<Expense> expenses;

  @override
  Widget build(BuildContext context) {
    final totals = {
      for (final item in ExpenseAnalytics.categoryBreakdown(expenses))
        item.category: item.total,
    };
    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ExpenseCategory.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final category = ExpenseCategory.values[index];
          return SizedBox(
            width: 132,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(category.icon, color: category.color),
                    const Spacer(),
                    Text(category.label),
                    Text(
                      AppFormatters.compactCurrency.format(
                        totals[category] ?? 0,
                      ),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight});

  final SpendingInsight insight;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: ListTile(
        leading: const Icon(Icons.lightbulb_outline),
        title: Text(insight.title),
        subtitle: Text('${insight.body} Locally generated, not AI advice.'),
      ),
    );
  }
}
