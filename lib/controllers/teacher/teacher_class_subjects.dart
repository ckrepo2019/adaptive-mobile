import 'dart:convert';
import 'package:Adaptive/config/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_response.dart';

class TeacherSubjectController {
  // --- Resolve stored token ---
  static Future<String?> _resolveToken(String? token) async {
    if (token != null && token.isNotEmpty) return token;
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString('token');
    // DEBUG
    // ignore: avoid_print
    print('🔐 _resolveToken -> ${t != null ? 'token present' : 'NULL'}');
    return t;
  }

  // --- Resolve teacher ID (from SharedPreferences if not passed) ---
  static Future<int?> _resolveTeacherId([int? teacherId]) async {
    if (teacherId != null && teacherId > 0) return teacherId;
    final prefs = await SharedPreferences.getInstance();

    // Prefer teacher_ID; fallback to id
    final tid = prefs.getInt('teacher_ID') ?? prefs.getInt('id');
    // DEBUG
    // ignore: avoid_print
    print('👨‍🏫 _resolveTeacherId -> teacher_ID=${prefs.getInt('teacher_ID')} | id=${prefs.getInt('id')} | resolved=$tid');
    return tid;
  }

  /// Fetch all subjects/classes for a teacher
  /// Matches response shape of /api/teacher/{teacherId}/classes (your sample JSON)
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

    // ✅ Use the endpoint that produced your JSON blob
    final base = '${AppConstants.baseURL}/teacher-subjects/$resolvedId';
    final uri = Uri.parse(base).replace(
      queryParameters: (query != null && query.trim().isNotEmpty)
          ? {'q': query.trim()}
          : null,
    );

    // DEBUG
    // ignore: avoid_print
    print('🌐 GET $uri');
    try {
      final res = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $resolvedToken',
        },
      );

      // DEBUG raw
      // ignore: avoid_print
      print('📥 HTTP ${res.statusCode}\n${res.body}');

      final dynamic body = res.body.isEmpty ? {} : jsonDecode(res.body);

      // DEBUG parsed
      // ignore: avoid_print
      print('🧩 Parsed keys: ${body is Map ? body.keys.toList() : body.runtimeType}');

      if (res.statusCode == 200 && body is Map && body['success'] == true) {
        // Map to the keys that actually exist in your JSON
        final data = <String, dynamic>{
          'yearLevels'    : (body['yearLevels']    is List) ? List<dynamic>.from(body['yearLevels'])    : <dynamic>[],
          'schoolYears'   : (body['schoolYears']   is List) ? List<dynamic>.from(body['schoolYears'])   : <dynamic>[],
          'semesters'     : (body['semesters']     is List) ? List<dynamic>.from(body['semesters'])     : <dynamic>[],
          'coTeachers'    : (body['coTeachers']    is List) ? List<dynamic>.from(body['coTeachers'])    : <dynamic>[],
          'teachers'      : (body['teachers']      is List) ? List<dynamic>.from(body['teachers'])      : <dynamic>[],
          'subjects'      : (body['subjects']      is List) ? List<dynamic>.from(body['subjects'])      : <dynamic>[],
          'subjectHeaders': (body['subjectHeaders']is List) ? List<dynamic>.from(body['subjectHeaders']): <dynamic>[],
          'filters'       : (body['filters']       is Map ) ? Map<String, dynamic>.from(body['filters']) : <String, dynamic>{},
        };

        // DEBUG counts
        // ignore: avoid_print
        print('✅ Parsed: subjects=${(data['subjects'] as List).length} | subjectHeaders=${(data['subjectHeaders'] as List).length}');

        return ApiResponse(success: true, data: data);
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

    // DEBUG
    // ignore: avoid_print
    print('🌐 GET $uri');

    try {
      final res = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $resolvedToken',
        },
      );

      // DEBUG
      // ignore: avoid_print
      print('📥 HTTP ${res.statusCode}\n${res.body}');

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
