extension MonthDate on DateTime {
  DateTime get monthStart => DateTime(year, month);

  DateTime get previousMonth =>
      month == 1 ? DateTime(year - 1, 12) : DateTime(year, month - 1);

  bool isSameMonth(DateTime other) =>
      year == other.year && month == other.month;
}
