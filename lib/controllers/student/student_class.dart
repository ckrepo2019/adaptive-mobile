// lib/controllers/student_class.dart
import 'dart:convert';
import 'package:flutter_lms/config/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_response.dart';

class StudentClassController {
  static Future<String?> _resolveToken(String? token) async {
    if (token != null && token.isNotEmpty) return token;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<int?> _resolveStudentId([int? studentId]) async {
    if (studentId != null && studentId > 0) return studentId;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id');
  }

  /// Fetch enrolled classes for a student.
  /// Backend response:
  /// {
  ///   success: true,
  ///   subjects: [...],
  ///   subjects_with_units: [...]
  /// }
  static Future<ApiResponse<Map<String, dynamic>>> fetchClasses({
    String? token,
    String? query,
    int? studentId, // optional override; otherwise taken from SharedPreferences
  }) async {
    final resolvedToken = await _resolveToken(token);
    if (resolvedToken == null) {
      return ApiResponse(
        success: false,
        message: 'Missing auth token. Pass token or login first.',
      );
    }

    final resolvedId = await _resolveStudentId(studentId);
    if (resolvedId == null || resolvedId <= 0) {
      return ApiResponse(
        success: false,
        message:
            'Missing student id. Save it in SharedPreferences as "id" or pass studentId.',
      );
    }

    // Build: /student-classes/{id}?query=...
    final base = '${AppConstants.baseURL}/student-classes/$resolvedId';
    final uri = Uri.parse(base).replace(
      queryParameters: (query != null && query.trim().isNotEmpty)
          ? {'query': query.trim()}
          : null,
    );

    try {
      final res = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $resolvedToken',
        },
      );

      final body = jsonDecode(res.body.isEmpty ? '{}' : res.body);
      if (res.statusCode == 200 && body is Map && body['success'] == true) {
        return ApiResponse(
          success: true,
          data: {
            'subjects': (body['subjects'] is List)
                ? List<dynamic>.from(body['subjects'])
                : <dynamic>[],
            'subjects_with_units': (body['subjects_with_units'] is List)
                ? List<dynamic>.from(body['subjects_with_units'])
                : <dynamic>[],
          },
        );
      }

      final msg = (body is Map && body['message'] != null)
          ? body['message'].toString()
          : 'Fetch failed (${res.statusCode})';
      return ApiResponse(success: false, message: msg);
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }
}
