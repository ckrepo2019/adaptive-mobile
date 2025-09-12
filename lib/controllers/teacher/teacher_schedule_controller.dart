import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Adaptive/config/constants.dart';
import 'package:Adaptive/controllers/api_response.dart';

class TeacherScheduleController {
  /// Resolve stored token if not provided.
  static Future<String?> _resolveToken(String? token) async {
    if (token != null && token.isNotEmpty) return token;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Fetch today’s schedule.
  static Future<ApiResponse<Map<String, dynamic>>> fetchTodaySchedule({
    String? token,
  }) async {
    final resolvedToken = await _resolveToken(token);
    if (resolvedToken == null) {
      return ApiResponse(
        success: false,
        message: 'Missing auth token. Please log in again.',
      );
    }

    final uri = Uri.parse('${AppConstants.baseURL}/teacher/schedule/today');

    try {
      if (kDebugMode) debugPrint('📡 GET $uri');

      final res = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $resolvedToken',
        },
      );

      final body = jsonDecode(res.body.isEmpty ? '{}' : res.body);

      if (kDebugMode) {
        debugPrint('🧾 Status: ${res.statusCode}');
        debugPrint('🧾 Body: $body');
      }

      if (res.statusCode == 200 && body is Map && body['success'] == true) {
        return ApiResponse(
          success: true,
          data: {
            'date': body['date'],
            'day': body['day'],
            'count': body['count'],
            'classes': (body['classes'] as List<dynamic>? ?? [])
                .whereType<Map>()
                .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
                .toList(),
          },
        );
      }

      final msg = (body is Map && body['message'] != null)
          ? body['message'].toString()
          : 'Failed to fetch schedule (${res.statusCode})';

      return ApiResponse(success: false, message: msg);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  /// Fetch and **print all classes grouped per day** for debugging/logging.
  static Future<ApiResponse<List<Map<String, dynamic>>>> fetchWeeklySchedule({
    String? token,
  }) async {
    final resolvedToken = await _resolveToken(token);
    if (resolvedToken == null) {
      return ApiResponse(
        success: false,
        message: 'Missing auth token. Please log in again.',
      );
    }

    final uri = Uri.parse('${AppConstants.baseURL}/teacher/schedule/week');

    try {
      if (kDebugMode) debugPrint('📡 GET $uri');

      final res = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $resolvedToken',
        },
      );

      final body = jsonDecode(res.body.isEmpty ? '{}' : res.body);

      if (kDebugMode) {
        debugPrint('🧾 Status: ${res.statusCode}');
        debugPrint('🧾 Body: $body');
      }

      if (res.statusCode == 200 && body is Map && body['success'] == true) {
        final classes = (body['classes'] as List<dynamic>? ?? [])
            .whereType<Map>()
            .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
            .toList();

        // Group by weekday for printing
        final Map<String, List<Map<String, dynamic>>> grouped = {};
        for (final c in classes) {
          final day = c['day']?.toString() ?? 'Unknown';
          grouped.putIfAbsent(day, () => []).add(c);
        }

        // Print grouped schedule
        grouped.forEach((day, list) {
          debugPrint('📅 $day: ${list.length} class(es)');
          for (final cls in list) {
            debugPrint(
              '   ⏰ ${cls['start_time']} - ${cls['end_time']} | '
              '${cls['subject_name']} (${cls['section_name']})',
            );
          }
        });

        return ApiResponse(success: true, data: classes);
      }

      final msg = (body is Map && body['message'] != null)
          ? body['message'].toString()
          : 'Failed to fetch weekly schedule (${res.statusCode})';

      return ApiResponse(success: false, message: msg);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: $e',
      );
    }
  }
}
