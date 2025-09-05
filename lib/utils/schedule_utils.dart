import 'time_utils.dart';

class ScheduleUtils {
  static int? dayIndexFromRow(dynamic row) {
    if (row is! Map) return null;

    for (final k in row.keys) {
      final key = k.toString().toLowerCase();
      if (key == 'day_id' ||
          key == 'day_index' ||
          key == 'day_num' ||
          key == 'day_of_week' ||
          key == 'dayno' ||
          key == 'daynumber') {
        final v = row[k];
        final parsed = _toIntOrNull(v);
        final idx = _normalizeIndex(parsed);
        if (idx != null) return idx;
      }
    }

    final d = row['day'];
    final parsed = _toIntOrNull(d);
    final idx = _normalizeIndex(parsed);
    if (idx != null) return idx;

    final rawName = (row['day_name'] ?? row['day'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    if (rawName.isEmpty || rawName == 'today' || rawName == 'tomorrow') {
      return null;
    }

    final k = rawName.length >= 3 ? rawName.substring(0, 3) : rawName;
    switch (k) {
      case 'mon':
        return 1;
      case 'tue':
        return 2;
      case 'wed':
        return 3;
      case 'thu':
        return 4;
      case 'fri':
        return 5;
      case 'sat':
        return 6;
      case 'sun':
        return 7;
    }
    return null;
  }

  static String labelForDayIndex(int idx1to7, Map<int, String> bestSeen) {
    const fallback = {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      7: 'Sunday',
    };
    final v = bestSeen[idx1to7];
    if (v != null && v.isNotEmpty) return v;
    return fallback[idx1to7]!;
  }

  static List<String> compressDayRanges(
    List<int> idxs,
    Map<int, String> bestSeen,
  ) {
    if (idxs.isEmpty) return const [];
    final parts = <String>[];

    String makeRange(int a, int b) {
      final A = labelForDayIndex(a, bestSeen);
      final B = labelForDayIndex(b, bestSeen);
      return (a == b) ? A : '$A - $B';
    }

    int start = idxs.first;
    int prev = idxs.first;

    for (int i = 1; i < idxs.length; i++) {
      final cur = idxs[i];
      if (cur == prev + 1) {
        prev = cur;
        continue;
      }
      parts.add(makeRange(start, prev));
      start = prev = cur;
    }
    parts.add(makeRange(start, prev));
    return parts;
  }

  static String formatSchedule(List<dynamic>? schedule, {DateTime? now}) {
    if (schedule == null || schedule.isEmpty) return '';

    final idxSet = <int>{};
    final bestLabel = <int, String>{};

    for (final row in schedule) {
      if (row is! Map) continue;

      String label = (row['day_name'] ?? row['day'] ?? '').toString().trim();
      if (label.isNotEmpty) {
        label = label[0].toUpperCase() + label.substring(1).toLowerCase();
      }

      final idx = dayIndexFromRow(row);
      if (idx == null) continue;

      idxSet.add(idx);
      if (label.isNotEmpty) {
        if (!bestLabel.containsKey(idx) ||
            label.length > bestLabel[idx]!.length) {
          bestLabel[idx] = label;
        }
      }
    }

    final idxs = idxSet.toList()..sort();
    if (idxs.isEmpty) {
      final first = schedule.first as Map;
      final startTime = TimeUtils.fmtTime(
        (first['start_time'] ?? '').toString(),
      );
      final endTime = TimeUtils.fmtTime((first['end_time'] ?? '').toString());
      return (startTime.isNotEmpty && endTime.isNotEmpty)
          ? '$startTime–$endTime'
          : '';
    }

    final rangeParts = compressDayRanges(idxs, bestLabel);

    String dayPart;
    if (rangeParts.length == 1) {
      dayPart = rangeParts.first;
    } else if (rangeParts.length == 2) {
      dayPart = '${rangeParts[0]} & ${rangeParts[1]}';
    } else {
      dayPart =
          '${rangeParts.sublist(0, rangeParts.length - 1).join(', ')} & ${rangeParts.last}';
    }

    final first = schedule.first as Map;
    final startTime = TimeUtils.fmtTime((first['start_time'] ?? '').toString());
    final endTime = TimeUtils.fmtTime((first['end_time'] ?? '').toString());
    final timePart = (startTime.isNotEmpty && endTime.isNotEmpty)
        ? ' • $startTime–$endTime'
        : '';

    return '$dayPart$timePart';
  }

  static int? _toIntOrNull(Object? v) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }

  static int? _normalizeIndex(int? n) {
    if (n == null) return null;
    if (n >= 1 && n <= 7) return n;
    if (n >= 0 && n <= 6) return n + 1;
    return null;
  }
}
