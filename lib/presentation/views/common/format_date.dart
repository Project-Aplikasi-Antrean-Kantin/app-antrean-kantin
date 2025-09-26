import 'package:intl/intl.dart';

class FormatDate {
  static String dateTimeToStringDate(DateTime date) {
    final format = DateFormat('dd MMMM yyyy', 'id_ID');
    return format.format(date);
  }

  static String dateTimeToStringTime(DateTime date) {
    final localDate = date.toLocal(); // konversi ke waktu lokal
    final format = DateFormat('HH:mm', 'id_ID');
    return format.format(localDate);
  }

  static String dateToDay(DateTime date) {
    final format = DateFormat('dd MMMM', 'id_ID');
    return format.format(date);
  }

  static String formatDateTimeWithWIB(DateTime dateTime) {
    // Format date to "dd MMMM yyyy HH:mm" format
    final DateFormat formatter = DateFormat('dd MMMM yyyy HH:mm', 'id_ID');
    String formatted = formatter.format(dateTime);

    // Add "WIB" timezone manually
    return '$formatted';
  }
}
