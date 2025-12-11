import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime date) {
    return DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(date);
  }
  
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm:ss', 'id_ID').format(date);
  }
  
  static String formatDateTime(DateTime date) {
    return '${formatDate(date)} ${formatTime(date)}';
  }
}

