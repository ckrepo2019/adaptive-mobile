import 'package:intl/intl.dart';

/// Time/date helpers.
class TimeUtils {
  /// Formats "08:00:00" => "8:00 AM".
  /// If parsing fails, returns the original string.
  static String fmtTime(String hhmmss) {
    try {
      final dt = DateFormat('HH:mm:ss').parse(hhmmss);
      return DateFormat('h:mm a').format(dt);
    } catch (_) {
      return hhmmss;
    }
  }
}
