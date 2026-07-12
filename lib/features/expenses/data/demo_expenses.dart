import '../domain/expense.dart';

class DemoExpenses {
  const DemoExpenses._();

  static List<Expense> seed(DateTime now) {
    final month = DateTime(now.year, now.month);
    final previous = month.month == 1
        ? DateTime(month.year - 1, 12)
        : DateTime(month.year, month.month - 1);

    return [
      Expense(
        id: 'seed-1',
        title: 'Groceries',
        merchant: 'Fresh Market',
        amount: 64.35,
        category: ExpenseCategory.food,
        date: month.add(const Duration(days: 1)),
        note: 'Weekly produce and pantry items',
      ),
      Expense(
        id: 'seed-2',
        title: 'Metro card top-up',
        merchant: 'City Transit',
        amount: 28.00,
        category: ExpenseCategory.transport,
        date: month.add(const Duration(days: 3)),
      ),
      Expense(
        id: 'seed-3',
        title: 'Electricity bill',
        merchant: 'North Grid Energy',
        amount: 92.18,
        category: ExpenseCategory.bills,
        date: month.add(const Duration(days: 5)),
      ),
      Expense(
        id: 'seed-4',
        title: 'Running shoes',
        merchant: 'Stride Supply',
        amount: 118.49,
        category: ExpenseCategory.shopping,
        date: month.add(const Duration(days: 7)),
      ),
      Expense(
        id: 'seed-5',
        title: 'Pharmacy',
        merchant: 'CarePlus Pharmacy',
        amount: 21.75,
        category: ExpenseCategory.health,
        date: month.add(const Duration(days: 9)),
      ),
      Expense(
        id: 'seed-6',
        title: 'Dinner with team',
        merchant: 'Harbor Table',
        amount: 47.90,
        category: ExpenseCategory.food,
        date: month.add(const Duration(days: 11)),
      ),
      Expense(
        id: 'seed-7',
        title: 'Movie night',
        merchant: 'CineHall',
        amount: 31.20,
        category: ExpenseCategory.entertainment,
        date: month.add(const Duration(days: 13)),
      ),
      Expense(
        id: 'seed-8',
        title: 'Coffee subscription',
        merchant: 'Bean Club',
        amount: 18.00,
        category: ExpenseCategory.food,
        date: previous.add(const Duration(days: 4)),
      ),
      Expense(
        id: 'seed-9',
        title: 'Internet bill',
        merchant: 'FiberOne',
        amount: 59.99,
        category: ExpenseCategory.bills,
        date: previous.add(const Duration(days: 10)),
      ),
      Expense(
        id: 'seed-10',
        title: 'Taxi to airport',
        merchant: 'RideNow',
        amount: 42.50,
        category: ExpenseCategory.transport,
        date: previous.add(const Duration(days: 15)),
      ),
    ];
  }
}
