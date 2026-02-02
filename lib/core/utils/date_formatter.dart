import 'package:intl/intl.dart';

/// Date and time formatting utilities
class DateFormatter {
  DateFormatter._();

  // Date formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String timeFormat = 'HH:mm';
  static const String monthYearFormat = 'MMMM yyyy';
  static const String dayMonthFormat = 'dd MMMM';
  static const String fullDateFormat = 'EEEE, dd MMMM yyyy';

  /// Format date to string
  static String formatDate(DateTime date, {String format = dateFormat}) {
    return DateFormat(format).format(date);
  }

  /// Format time to string
  static String formatTime(DateTime time) {
    return DateFormat(timeFormat).format(time);
  }

  /// Format date time to string
  static String formatDateTime(DateTime dateTime) {
    return DateFormat(dateTimeFormat).format(dateTime);
  }

  /// Get relative time (e.g., "2 hours ago", "Yesterday")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return formatDate(dateTime);
    }
  }

  /// Parse string to date
  static DateTime? parseDate(String dateString, {String format = dateFormat}) {
    try {
      return DateFormat(format).parse(dateString);
    } catch (e) {
      return null;
    }
  }
}
