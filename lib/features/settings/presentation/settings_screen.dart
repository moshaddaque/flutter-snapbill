import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_tokens.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../expenses/presentation/expense_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: 'Settings',
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const Card(
            child: ListTile(
              leading: Icon(Icons.storage_outlined),
              title: Text('Offline first'),
              subtitle: Text(
                'Expenses are stored locally in SQLite on this device.',
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Card(
            child: ListTile(
              leading: Icon(Icons.document_scanner_outlined),
              title: Text('Receipt scanning'),
              subtitle: Text(
                'Receipt text recognition runs on device and extracted details can be reviewed before saving.',
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.tonalIcon(
            onPressed: () async {
              await ref
                  .read(expenseControllerProvider.notifier)
                  .resetDemoData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All expenses cleared')),
                );
              }
            },
            icon: const Icon(Icons.delete_sweep_outlined),
            label: const Text('Clear all expenses'),
          ),
        ],
      ),
    );
  }
}
