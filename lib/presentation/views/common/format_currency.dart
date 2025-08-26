import 'package:intl/intl.dart';

class FormatCurrency {
  static String intToStringCurrency(int amount) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );
    return formatCurrency.format(amount);
  }

  static String intToStringCoin(int amount) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );
    return formatCurrency.format(amount);
  }

  static String stringCoin(String amount) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );
    return formatCurrency.format(int.parse(amount));
  }

  static String stringCurrency(String amount) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );
    // Convert String to int (or double if needed)
    return formatCurrency.format(int.parse(amount));
  }

  static String formatNumber(String nominal) {
    return nominal.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => "${m[1]}.",
    );
  }
}
