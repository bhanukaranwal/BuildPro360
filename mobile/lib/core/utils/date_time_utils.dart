import 'package:intl/intl.dart';

class DateTimeUtils {
  static String formatDate(DateTime? dateTime, {String format = 'MMM d, yyyy'}) {
    if (dateTime == null) {
      return 'N/A';
    }
    return DateFormat(format).format(dateTime);
  }
  
  static String formatDateTime(DateTime? dateTime, {String format = 'MMM d, yyyy h:mm a'}) {
    if (dateTime == null) {
      return 'N/A';
    }
    return DateFormat(format).format(dateTime);
  }
  
  static String getTimeAgo(DateTime? dateTime) {
    if (dateTime == null) {
      return 'N/A';
    }
    
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else {
      return '${(difference.inDays / 365).floor()}y ago';
    }
  }
  
  static DateTime? parseDate(String? dateString, {String format = 'yyyy-MM-dd'}) {
    if (dateString == null || dateString.isEmpty) {
      return null;
    }
    
    try {
      return DateFormat(format).parse(dateString);
    } catch (e) {
      return null;
    }
  }
  
  static DateTime? parseDateTime(String? dateTimeString, {String format = 'yyyy-MM-dd HH:mm:ss'}) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return null;
    }
    
    try {
      return DateFormat(format).parse(dateTimeString);
    } catch (e) {
      try {
        // Try parsing as ISO date
        return DateTime.parse(dateTimeString);
      } catch (e) {
        return null;
      }
    }
  }
  
  static String getRemainingTime(DateTime? endDate) {
    if (endDate == null) {
      return 'No deadline';
    }
    
    final difference = endDate.difference(DateTime.now());
    
    if (difference.isNegative) {
      return 'Overdue';
    }
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} left';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} left';
    } else {
      return 'Less than a minute left';
    }
  }
  
  static bool isOverdue(DateTime? deadline) {
    if (deadline == null) {
      return false;
    }
    
    return DateTime.now().isAfter(deadline);
  }
  
  static bool isSameDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) {
      return false;
    }
    
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }
  
  static DateTime startOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }
  
  static DateTime endOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59, 999);
  }
  
  static DateTime startOfWeek(DateTime dateTime) {
    final difference = dateTime.weekday - 1;
    return startOfDay(dateTime.subtract(Duration(days: difference)));
  }
  
  static DateTime endOfWeek(DateTime dateTime) {
    final difference = 7 - dateTime.weekday;
    return endOfDay(dateTime.add(Duration(days: difference)));
  }
  
  static DateTime startOfMonth(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, 1);
  }
  
  static DateTime endOfMonth(DateTime dateTime) {
    return endOfDay(DateTime(dateTime.year, dateTime.month + 1, 0));
  }
}