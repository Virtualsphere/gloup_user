import 'package:intl/intl.dart';

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  String titleCase() {
    return split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  String formatDobDate() {
    DateTime time = DateTime.parse(this);
    String formattedDate = DateFormat('d MMM yyyy').format(time);
    return formattedDate;
  }

  String formatSingleDate(String format) {
    DateTime time = DateTime.parse(this);
    return DateFormat(format).format(time);
  }

  String getShortMonthName() {
    try {
      final date = DateTime.parse(this);
      return DateFormat.MMM().format(date);
    } catch (e) {
      return '-';
    }
  }

  String toHoursAndMinutes() {
    try {
      List<String> parts = split(':');
      if (parts.length < 2) return this;
      int hours = int.parse(parts[0]);
      int minutes = int.parse(parts[1]);
      String result = '';
      if (hours > 0) result += '$hours hr${hours > 1 ? 's' : ''} ';
      if (minutes > 0) result += '$minutes min${minutes > 1 ? 's' : ''}';
      return result.trim();
    } catch (e) {
      return this;
    }
  }
}
