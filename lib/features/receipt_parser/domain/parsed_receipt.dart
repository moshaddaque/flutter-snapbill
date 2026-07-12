import '../../expenses/domain/expense.dart';

class ParsedReceipt {
  const ParsedReceipt({
    required this.merchant,
    required this.amount,
    required this.date,
    required this.suggestedCategory,
    this.currencyCode = 'USD',
    this.subtotal,
    this.tax,
    this.discount,
    this.timeText,
    this.items = const [],
    this.confidence = const ReceiptParseConfidence(),
    this.originalText = '',
    this.normalizedText = '',
  });

  final String merchant;
  final double amount;
  final DateTime date;
  final ExpenseCategory suggestedCategory;
  final String currencyCode;
  final double? subtotal;
  final double? tax;
  final double? discount;
  final String? timeText;
  final List<ParsedReceiptItem> items;
  final ReceiptParseConfidence confidence;
  final String originalText;
  final String normalizedText;
}

class ParsedReceiptItem {
  const ParsedReceiptItem({
    required this.name,
    required this.lineTotal,
    this.quantity,
    this.unitPrice,
    this.confidence = .7,
  });

  final String name;
  final double lineTotal;
  final double? quantity;
  final double? unitPrice;
  final double confidence;

  ParsedReceiptItem copyWith({
    String? name,
    double? quantity,
    double? unitPrice,
    double? lineTotal,
    double? confidence,
  }) {
    return ParsedReceiptItem(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      lineTotal: lineTotal ?? this.lineTotal,
      confidence: confidence ?? this.confidence,
    );
  }
}

class ReceiptParseConfidence {
  const ReceiptParseConfidence({
    this.overall = 0,
    this.merchant = 0,
    this.date = 0,
    this.total = 0,
    this.items = 0,
  });

  final double overall;
  final double merchant;
  final double date;
  final double total;
  final double items;

  String get level {
    if (overall >= .8) return 'High';
    if (overall >= .55) return 'Medium';
    return 'Low';
  }
}
