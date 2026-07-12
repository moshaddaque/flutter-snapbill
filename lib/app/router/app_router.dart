import 'package:go_router/go_router.dart';

import '../../features/analytics/presentation/analytics_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/expenses/presentation/add_expense_screen.dart';
import '../../features/expenses/presentation/expense_detail_screen.dart';
import '../../features/expenses/presentation/expense_history_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/receipt_parser/presentation/receipt_preview_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
    GoRoute(
      path: '/add',
      builder: (context, state) => const AddExpenseScreen(),
    ),
    GoRoute(
      path: '/receipt',
      builder: (context, state) => const ReceiptPreviewScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const ExpenseHistoryScreen(),
    ),
    GoRoute(
      path: '/expense/:id',
      builder: (context, state) =>
          ExpenseDetailScreen(expenseId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/analytics',
      builder: (context, state) => const AnalyticsScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
