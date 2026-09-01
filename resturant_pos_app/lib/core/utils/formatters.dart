import 'package:intl/intl.dart';

class Formatters {
  static String formatCurrency(double amount, {String symbol = 'Rs. '}) {
    final format = NumberFormat.currency(symbol: symbol, decimalDigits: 2);
    return format.format(amount);
  }

  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('yyyy-MM-dd hh:mm a').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }
}
