import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Adaptive/config/constants.dart';
import 'package:Adaptive/controllers/api_response.dart';

class TeacherSubjectStudentController {
  /// Resolve stored token if not provided.
  static Future<String?> _resolveToken(String? token) async {
    if (token != null && token.isNotEmpty) return token;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Utility: safe cast to `Map<String, dynamic>`
  static Map<String, dynamic> _asStringMap(dynamic v) {
    if (v is Map) {
      return v.map((k, val) => MapEntry(k.toString(), val));
    }
    return <String, dynamic>{};
  }

  /// Utility: safe cast a list of maps
  static List<Map<String, dynamic>> _asListOfStringMap(dynamic v) {
    if (v is List) {
      return v
          .where((e) => e is Map)
          .map((e) => (e as Map).map((k, val) => MapEntry(k.toString(), val)))
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  /// Fetch students enrolled under a specific subject (and optionally a section)
  ///
  /// Backend route (from our PHP controller spec):
  /// GET /api/teacher/subjects/{subjectId}/students
  ///
  /// Optional query parameters:
  /// - q          : filter by name/section/etc.
  /// - page       : pagination page (if backend is paginated)
  /// - per_page   : page size
  /// - section_id : narrow the results to a specific section for that subject
  static Future<ApiResponse<Map<String, dynamic>>> fetchSubjectStudents({
    required int subjectId,
    int? sectionId,
    String? query,
    int? page,
    int? perPage,
    String? token,
  }) async {
    if (subjectId <= 0) {
      return ApiResponse(
        success: false,
        message: 'Invalid subjectId.',
      );
    }

    final resolvedToken = await _resolveToken(token);
    if (resolvedToken == null) {
      return ApiResponse(
        success: false,
        message: 'Missing auth token. Please login again.',
      );
    }

    final base = '${AppConstants.baseURL}/teacher/subjects/$subjectId/students';

    final qp = <String, String>{};
    if (query != null && query.trim().isNotEmpty) qp['q'] = query.trim();
    if (page != null && page > 0) qp['page'] = '$page';
    if (perPage != null && perPage > 0) qp['per_page'] = '$perPage';
    if (sectionId != null && sectionId > 0) qp['section_id'] = '$sectionId';

    final uri = Uri.parse(base).replace(queryParameters: qp.isEmpty ? null : qp);

    try {
      if (kDebugMode) {
        debugPrint('📡 GET $uri');
      }

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

      // Expected structure (recommended from our PHP design):
      // {
      //   success: true,
      //   subject: {...},        // meta about subject
      //   section: {...},        // (optional) involved section
      //   students: [ {...}, ...],
      //   meta: { page, per_page, total, ... }  // optional
      // }
      if (res.statusCode == 200 && body is Map && body['success'] == true) {
        final subject = _asStringMap(body['subject']);
        final section = _asStringMap(body['section']);
        final students = _asListOfStringMap(body['students']);
        final meta = _asStringMap(body['meta']);

        return ApiResponse(
          success: true,
          data: {
            'subject': subject,
            'section': section,
            'students': students,
            'meta': meta,
          },
        );
      }

      // Some backends return {success:false, message:'...'}
      final msg = (body is Map && body['message'] != null)
          ? body['message'].toString()
          : 'Fetch failed (${res.statusCode})';
      return ApiResponse(success: false, message: msg);
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }
}
