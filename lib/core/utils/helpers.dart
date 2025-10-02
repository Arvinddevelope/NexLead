import 'package:intl/intl.dart';

class Helpers {
  /// Format date to a readable string
  static String formatDate(DateTime date) {
    final formatter = DateFormat('MMM dd, yyyy');
    return formatter.format(date);
  }

  /// Format date and time to a readable string
  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('MMM dd, yyyy HH:mm');
    return formatter.format(dateTime);
  }

  /// Format time to a readable string
  static String formatTime(DateTime time) {
    final formatter = DateFormat('HH:mm');
    return formatter.format(time);
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// Get initials from a name
  static String getInitials(String name) {
    if (name.isEmpty) return '';

    final names = name.split(' ');
    if (names.length == 1) {
      return names[0].substring(0, 1).toUpperCase();
    } else {
      return '${names[0].substring(0, 1)}${names[names.length - 1].substring(0, 1)}'
          .toUpperCase();
    }
  }

  /// Truncate text with ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Capitalize first letter of each word
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).join(' ');
  }
}
