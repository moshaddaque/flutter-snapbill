import 'package:flutter/material.dart';

enum ExpenseCategory {
  food('Food', Icons.restaurant_outlined, Color(0xFFE76F51)),
  transport('Transport', Icons.directions_car_outlined, Color(0xFF457B9D)),
  shopping('Shopping', Icons.shopping_bag_outlined, Color(0xFF7C6AEE)),
  bills('Bills', Icons.receipt_long_outlined, Color(0xFFE9B44C)),
  health('Health', Icons.health_and_safety_outlined, Color(0xFF2A9D8F)),
  entertainment('Entertainment', Icons.movie_outlined, Color(0xFF9B5DE5)),
  other('Other', Icons.category_outlined, Color(0xFF6C757D));

  const ExpenseCategory(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;

  static ExpenseCategory fromName(String name) {
    return ExpenseCategory.values.firstWhere(
      (category) => category.name == name,
      orElse: () => ExpenseCategory.other,
    );
  }
}

class Expense {
  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
    this.receiptImagePath,
    this.merchant,
  });

  final String id;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final String? note;
  final String? receiptImagePath;
  final String? merchant;

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    String? note,
    String? receiptImagePath,
    String? merchant,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      merchant: merchant ?? this.merchant,
    );
  }
}
