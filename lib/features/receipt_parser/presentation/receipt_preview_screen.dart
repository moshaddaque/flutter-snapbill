import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../expenses/domain/expense.dart';
import '../../expenses/presentation/expense_providers.dart';
import '../../expenses/presentation/expense_widgets.dart';

class ReceiptPreviewScreen extends ConsumerStatefulWidget {
  const ReceiptPreviewScreen({super.key});

  @override
  ConsumerState<ReceiptPreviewScreen> createState() =>
      _ReceiptPreviewScreenState();
}

class _ReceiptPreviewScreenState extends ConsumerState<ReceiptPreviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _imagePath;
  ExpenseCategory _category = ExpenseCategory.food;
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Attach Receipt',
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.receipt_long_outlined, size: 34),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Add a receipt image and enter the expense details manually.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _saving ? null : _pickImage,
                    icon: const Icon(Icons.image_outlined),
                    label: const Text('Choose image'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: _saving ? null : _captureImage,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Capture image'),
                  ),
                ),
              ],
            ),
            if (_imagePath != null) ...[
              const SizedBox(height: AppSpacing.md),
              _ReceiptImagePreview(imagePath: _imagePath!),
            ],
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              style: Theme.of(
                context,
              ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$ ',
              ),
              validator: (value) {
                final amount = double.tryParse(value ?? '');
                if (amount == null || amount <= 0) {
                  return 'Enter an amount greater than zero.';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Merchant or title',
                prefixIcon: Icon(Icons.store_outlined),
              ),
              validator: (value) {
                if ((value ?? '').trim().length < 2) {
                  return 'Add a merchant or expense title.';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            CategorySelector(
              selected: _category,
              onSelected: (category) => setState(() => _category = category),
            ),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: Text(AppFormatters.shortDate.format(_date)),
              subtitle: const Text('Expense date'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickDate,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Optional note',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: const Text('Save expense'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 2000,
      maxHeight: 2000,
      imageQuality: 92,
    );
    if (image != null && mounted) setState(() => _imagePath = image.path);
  }

  Future<void> _captureImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 2000,
      maxHeight: 2000,
      imageQuality: 92,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (image != null && mounted) setState(() => _imagePath = image.path);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 3),
      lastDate: DateTime(DateTime.now().year + 1),
      initialDate: _date,
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final controller = ref.read(expenseControllerProvider.notifier);
    await controller.addExpense(
      Expense(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        merchant: _titleController.text.trim(),
        amount: double.parse(_amountController.text),
        category: _category,
        date: _date,
        receiptImagePath: _imagePath,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      ),
      refresh: false,
    );
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    context.go('/');
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.reload();
      messenger.showSnackBar(const SnackBar(content: Text('Expense saved')));
    });
  }
}

class _ReceiptImagePreview extends StatelessWidget {
  const _ReceiptImagePreview({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: InkWell(
            onTap: () => _showFullImage(context),
            child: Image.file(
              File(imagePath),
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: AppSpacing.xs,
          right: AppSpacing.xs,
          child: IconButton.filledTonal(
            tooltip: 'View receipt',
            onPressed: () => _showFullImage(context),
            icon: const Icon(Icons.open_in_full),
          ),
        ),
      ],
    );
  }

  void _showFullImage(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog.fullscreen(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Receipt image'),
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ),
            body: InteractiveViewer(
              minScale: .7,
              maxScale: 5,
              child: Center(
                child: Image.file(File(imagePath), fit: BoxFit.contain),
              ),
            ),
          ),
        );
      },
    );
  }
}
