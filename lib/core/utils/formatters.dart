import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static final currency = NumberFormat.simpleCurrency(name: 'USD');
  static final compactCurrency = NumberFormat.compactSimpleCurrency(
    name: 'USD',
  );
  static final month = DateFormat('MMMM yyyy');
  static final shortDate = DateFormat('MMM d, yyyy');
}
