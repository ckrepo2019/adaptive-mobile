import 'dart:convert';
import 'package:Adaptive/config/constants.dart';
import 'package:Adaptive/controllers/api_response.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TeacherSectionsController {
  /// Resolve stored token from SharedPreferences if not passed
  static Future<String?> _resolveToken([String? token]) async {
    if (token != null && token.isNotEmpty) return token;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Resolve teacherId from SharedPreferences if not passed
  static Future<int?> _resolveTeacherId([int? teacherId]) async {
    if (teacherId != null && teacherId > 0) return teacherId;
    final prefs = await SharedPreferences.getInstance();
    // adjust if you save it under 'teacher_ID'
    return prefs.getInt('id');
  }

  /// Fetch all sections (adviser + teaching) with yearLevels, semesters, etc.
  static Future<ApiResponse<Map<String, dynamic>>> fetchSections({
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
        message: 'Missing teacher id. Save it in SharedPreferences.',
      );
    }

    final base = '${AppConstants.baseURL}/teacher/$resolvedId/sections';
    final uri = Uri.parse(base).replace(
      queryParameters: (query != null && query.trim().isNotEmpty)
          ? {'q': query.trim()}
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
            'sections': (body['sections'] is List)
                ? List<Map<String, dynamic>>.from(body['sections'])
                : <Map<String, dynamic>>[],
            'yearLevels': (body['yearLevels'] is List)
                ? List<Map<String, dynamic>>.from(body['yearLevels'])
                : <Map<String, dynamic>>[],
            'schoolYears': (body['schoolYears'] is List)
                ? List<Map<String, dynamic>>.from(body['schoolYears'])
                : <Map<String, dynamic>>[],
            'semesters': (body['semesters'] is List)
                ? List<Map<String, dynamic>>.from(body['semesters'])
                : <Map<String, dynamic>>[],
            'coTeachers': (body['coTeachers'] is List)
                ? List<Map<String, dynamic>>.from(body['coTeachers'])
                : <Map<String, dynamic>>[],
            'teachers': (body['teachers'] is List)
                ? List<Map<String, dynamic>>.from(body['teachers'])
                : <Map<String, dynamic>>[],
            'subjects': (body['subjects'] is List)
                ? List<Map<String, dynamic>>.from(body['subjects'])
                : <Map<String, dynamic>>[],
            'subjectHeaders': (body['subjectHeaders'] is List)
                ? List<Map<String, dynamic>>.from(body['subjectHeaders'])
                : <Map<String, dynamic>>[],
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
