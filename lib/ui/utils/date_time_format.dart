import 'package:intl/intl.dart';

String formatDateTime(String dateTimeString) {
  final DateTime dateTime = DateTime.parse(dateTimeString).toUtc().toLocal();

  final DateFormat formatter =
      DateFormat('dd-MM-yyyy HH:mm:ss'); // Adjust format as needed
  return formatter.format(dateTime);
}

String formatDateMonthYear(String dateTimeString) {
  final DateTime dateTime = DateTime.parse(dateTimeString).toUtc().toLocal();

  final DateFormat formatter =
      DateFormat('dd-MM-yyyy'); // Adjust format as needed
  return formatter.format(dateTime);
}

const _locale = 'en';
String formatNumber(String s) {
  return NumberFormat.decimalPattern(_locale).format(int.parse(s));
}
