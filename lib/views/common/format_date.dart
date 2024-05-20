import 'package:intl/intl.dart';

class FormatDate {
  String dateTimeToStringDate(DateTime date) {
    final format = DateFormat('dd MMMM yyyy');
    return format.format(date);
  }
}
