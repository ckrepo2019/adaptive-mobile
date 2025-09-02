import 'dart:convert';
import 'package:flutter_lms/config/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_response.dart';

class TeacherSubjectController {
  // --- Resolve stored token ---
  static Future<String?> _resolveToken(String? token) async {
    if (token != null && token.isNotEmpty) return token;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // --- Resolve teacher ID (from SharedPreferences if not passed) ---
  static Future<int?> _resolveTeacherId([int? teacherId]) async {
    if (teacherId != null && teacherId > 0) return teacherId;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('teacher_ID'); // must be saved after login
  }

  // --- Fetch all subjects for a teacher ---
  static Future<ApiResponse<Map<String, dynamic>>> fetchSubjects({
    String? token,
    int? teacherId,
    String? query,
  }) async {
    final resolvedToken = await _resolveToken(token);
    if (resolvedToken == null) {
      return ApiResponse(
        success: false,
        message: 'Missing auth token. Please login again.',
      );
    }

    final resolvedId = await _resolveTeacherId(teacherId);
    if (resolvedId == null || resolvedId <= 0) {
      return ApiResponse(
        success: false,
        message: 'Missing teacher id. Save it in SharedPreferences as "teacher_ID".',
      );
    }

    final base = '${AppConstants.baseURL}/teacher-subjects/$resolvedId';
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
            'yearLevel': (body['yearLevel'] is List)
                ? List<dynamic>.from(body['yearLevel'])
                : <dynamic>[],
            'schoolYear': (body['schoolYear'] is List)
                ? List<dynamic>.from(body['schoolYear'])
                : <dynamic>[],
            'semesters': (body['semesters'] is List)
                ? List<dynamic>.from(body['semesters'])
                : <dynamic>[],
            'coteachers': (body['coteachers'] is List)
                ? List<dynamic>.from(body['coteachers'])
                : <dynamic>[],
            'teachers': (body['teachers'] is List)
                ? List<dynamic>.from(body['teachers'])
                : <dynamic>[],
            'subjectlist': (body['subjectlist'] is List)
                ? List<dynamic>.from(body['subjectlist'])
                : <dynamic>[],
            'subjectHeaders': (body['subjectHeaders'] is List)
                ? List<dynamic>.from(body['subjectHeaders'])
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

  // --- Fetch details of a single subject (for teacher) ---
  static Future<ApiResponse<Map<String, dynamic>>> fetchSubjectDetails({
    required int subjectId,
    String? token,
  }) async {
    if (subjectId <= 0) {
      return ApiResponse(success: false, message: 'Invalid subjectId.');
    }

    final resolvedToken = await _resolveToken(token);
    if (resolvedToken == null) {
      return ApiResponse(
        success: false,
        message: 'Missing auth token. Please login again.',
      );
    }

    final uri = Uri.parse('${AppConstants.baseURL}/teacher-subject/$subjectId');

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
          data: Map<String, dynamic>.from(body),
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
