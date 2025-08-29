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

  static Future<ApiResponse<Map<String, dynamic>>> fetchClasses({
    String? token,
    String? query,
    int? studentId,
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

  static Future<ApiResponse<Map<String, dynamic>>> fetchClassSubject({
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
        message: 'Missing auth token. Pass token or login first.',
      );
    }

    final uri = Uri.parse('${AppConstants.baseURL}/class-subject/$subjectId');

    try {
      final res = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $resolvedToken',
        },
      );

      final raw = res.body.isEmpty ? '{}' : res.body;
      final body = jsonDecode(raw);

      if (res.statusCode == 200 && body is Map && body['success'] == true) {
        final subjects = (body['subjects'] is List)
            ? List<dynamic>.from(body['subjects'])
            : const <dynamic>[];

        final studentUser = (body['studentUser'] is Map)
            ? Map<String, dynamic>.from(body['studentUser'])
            : null;

        final listofStudents = (body['listofStudents'] is List)
            ? List<dynamic>.from(body['listofStudents'])
            : const <dynamic>[];

        final studentsCount = (body['students_count'] is num)
            ? (body['students_count'] as num).toInt()
            : 0;

        final classmateunits = (body['classmateunits'] is List)
            ? List<dynamic>.from(body['classmateunits'])
            : const <dynamic>[];

        final List<Map<String, dynamic>> assessments =
            (body['assessments'] is List)
            ? List<Map<String, dynamic>>.from(
                (body['assessments'] as List).map((e) {
                  return (e is Map)
                      ? Map<String, dynamic>.from(e)
                      : <String, dynamic>{};
                }),
              )
            : const <Map<String, dynamic>>[];

        final Map<String, dynamic>? firstContent =
            (body['first_content'] is Map)
            ? Map<String, dynamic>.from(body['first_content'])
            : null;

        return ApiResponse(
          success: true,
          data: {
            'subjects': subjects,
            'studentUser': studentUser,
            'listofStudents': listofStudents,
            'students_count': studentsCount,
            'classmateunits': classmateunits,
            'assessments': assessments,
            'first_content': firstContent,
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

  static Future<ApiResponse<Map<String, dynamic>>> joinClassByCode({
    required String classCode,
    String? token,
  }) async {
    if (classCode.trim().isEmpty) {
      return ApiResponse(success: false, message: 'Class code is required.');
    }

    final resolvedToken = await _resolveToken(token);
    if (resolvedToken == null) {
      return ApiResponse(
        success: false,
        message: 'Missing auth token. Pass token or login first.',
      );
    }

    final uri = Uri.parse('${AppConstants.baseURL}/student/classes/join');

    try {
      final res = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $resolvedToken',
        },
        body: jsonEncode({'class_code': classCode.trim()}),
      );

      final raw = res.body.isEmpty ? '{}' : res.body;
      final body = jsonDecode(raw);

      if (res.statusCode == 200 &&
          body is Map &&
          (body['success'] == true || body['message'] != null)) {
        final enrolledId = (body['enrolled_id'] is num)
            ? (body['enrolled_id'] as num).toInt()
            : null;
        final subjectId = (body['subject_id'] is num)
            ? (body['subject_id'] as num).toInt()
            : null;
        final message = (body['message'] ?? 'Joined successfully.').toString();

        return ApiResponse(
          success: true,
          message: message,
          data: {'enrolled_id': enrolledId, 'subject_id': subjectId},
        );
      }

      final msg = (body is Map && body['message'] != null)
          ? body['message'].toString()
          : (body is Map && body['error'] != null)
          ? body['error'].toString()
          : 'Join failed (${res.statusCode})';
      return ApiResponse(success: false, message: msg);
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }
}
