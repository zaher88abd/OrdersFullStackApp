class DateTimeUtils {
  /// Parse DateTime from various formats commonly used in GraphQL responses
  /// Handles:
  /// - ISO 8601 strings (e.g., "2023-01-01T10:00:00Z")
  /// - Milliseconds since epoch as integer
  /// - Milliseconds since epoch as string
  static DateTime parseDateTime(dynamic value) {
    if (value == null) {
      throw ArgumentError('DateTime value cannot be null');
    }

    if (value is String) {
      // Try parsing as ISO string first
      try {
        return DateTime.parse(value);
      } catch (e) {
        // If that fails, try parsing as milliseconds string
        final timestamp = int.tryParse(value);
        if (timestamp != null) {
          return DateTime.fromMillisecondsSinceEpoch(timestamp);
        }
        throw FormatException('Invalid date format: $value');
      }
    } else if (value is int) {
      // Handle milliseconds timestamp
      return DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is double) {
      // Handle milliseconds timestamp as double (convert to int)
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    } else {
      throw FormatException('Invalid date type: ${value.runtimeType}');
    }
  }

  /// Convert DateTime to ISO 8601 string for JSON serialization
  static String dateTimeToJson(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

  /// Format DateTime for display in UI
  static String formatForDisplay(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Format date only for display
  static String formatDateOnly(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  /// Format time only for display
  static String formatTimeOnly(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Get relative time string (e.g., "2 hours ago", "Yesterday")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else {
      return formatDateOnly(dateTime);
    }
  }

  /// Check if two DateTimes are on the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Check if DateTime is today
  static bool isToday(DateTime dateTime) {
    return isSameDay(dateTime, DateTime.now());
  }

  /// Check if DateTime is yesterday
  static bool isYesterday(DateTime dateTime) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(dateTime, yesterday);
  }
}