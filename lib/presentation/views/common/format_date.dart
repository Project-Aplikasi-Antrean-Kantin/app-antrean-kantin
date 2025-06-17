import 'package:intl/intl.dart';

class FormatDate {
  static String dateTimeToStringDate(DateTime date) {
    final format = DateFormat('dd MMMM yyyy');
    return format.format(date);
  }

  static String formatDateTimeWithWIB(DateTime dateTime) {
    // Format date to "dd MMMM yyyy HH:mm" format
    final DateFormat formatter = DateFormat('dd MMMM yyyy HH:mm', 'en_US');
    String formatted = formatter.format(dateTime);

    // Add "WIB" timezone manually
    return '$formatted WIB';
  }
}
