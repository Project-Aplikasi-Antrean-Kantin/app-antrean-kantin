import 'package:intl/intl.dart';

class FormatCurrency {
  String intToStringCurrency(int amount) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatCurrency.format(amount);
  }
}
