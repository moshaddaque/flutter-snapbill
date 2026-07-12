import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_tokens.dart';
import '../../../core/database/app_settings_store.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _onboardingCompletedKey = 'onboarding_completed';
  final _settings = const AppSettingsStore();

  @override
  void initState() {
    super.initState();
    _navigateFromStartup();
  }

  Future<void> _navigateFromStartup() async {
    await WidgetsBinding.instance.endOfFrame;
    var completed = false;
    try {
      completed = await _settings.getBool(_onboardingCompletedKey);
      if (!completed && await _settings.hasAnyExpense()) {
        await _settings.setBool(_onboardingCompletedKey, true);
        completed = true;
      }
    } catch (_) {
      completed = false;
    }
    if (!mounted) return;
    context.go(completed ? '/' : '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long, size: 64, color: AppColors.pine),
            SizedBox(height: 16),
            Text(
              'SnapBill',
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8),
            Text('Offline expense clarity'),
          ],
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _onboardingCompletedKey = 'onboarding_completed';
  final _settings = const AppSettingsStore();
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              const Icon(Icons.auto_graph, size: 72, color: AppColors.pine),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Premium spending control, built offline first.',
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Track expenses, scan receipts on device, review monthly analytics, and keep your data available offline.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _saving ? null : _completeOnboarding,
                icon: _saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_forward),
                label: const Text('Start tracking'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    setState(() => _saving = true);
    await _settings.setBool(_onboardingCompletedKey, true);
    if (!mounted) return;
    context.go('/');
  }
}
