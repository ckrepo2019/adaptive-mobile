import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Adaptive/config/constants.dart';
import 'package:Adaptive/controllers/api_response.dart';

class TeacherBookController {
  // ---------- Common helpers ----------

  static Future<String?> _resolveToken(String? token) async {
    if (token != null && token.isNotEmpty) return token;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Map<String, dynamic> _asStringMap(dynamic v) {
    if (v is Map) {
      return v.map((k, val) => MapEntry(k.toString(), val));
    }
    return <String, dynamic>{};
  }

  static List<Map<String, dynamic>> _asListOfStringMap(dynamic v) {
    if (v is List) {
      return v
          .where((e) => e is Map)
          .map((e) => (e as Map).map((k, val) => MapEntry(k.toString(), val)))
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  static Uri _uri(String path, [Map<String, String>? qp]) {
    final base = AppConstants.baseURL; // e.g. https://domain.tld/api/flutter
    final url = '$base$path';
    return Uri.parse(url).replace(queryParameters: (qp == null || qp.isEmpty) ? null : qp);
  }

  static Map<String, String> _headers(String token) => {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // ---------- API methods ----------

  /// GET /api/flutter/teacher/books
  /// Returns teacher-only grouped books:
  /// [{ bookID, courseware_name, description, created_at, image, collaborators[], teachers[] }]
  static Future<ApiResponse<Map<String, dynamic>>> fetchBooks({
    String? token,
  }) async {
    final resolvedToken = await _resolveToken(token);
    if (resolvedToken == null) {
      return ApiResponse(success: false, message: 'Missing auth token. Please login again.');
    }

    final uri = _uri('/teacher/books');

    try {
      if (kDebugMode) debugPrint('📡 GET $uri');
      final res = await http.get(uri, headers: _headers(resolvedToken));
      final body = jsonDecode(res.body.isEmpty ? '{}' : res.body);

      if (kDebugMode) {
        debugPrint('🧾 Status: ${res.statusCode}');
        debugPrint('🧾 Body: $body');
      }

      if (res.statusCode == 200 && body is Map && body['success'] == true) {
        final books = _asListOfStringMap(body['books']);
        return ApiResponse(success: true, data: {'books': books});
      }

      final msg = (body is Map && body['message'] != null)
          ? body['message'].toString()
          : 'Fetch failed (${res.statusCode})';
      return ApiResponse(success: false, message: msg);
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  /// GET /api/flutter/teacher/books/{id}
  /// (Enable this route in Laravel if you plan to use it)
  static Future<ApiResponse<Map<String, dynamic>>> fetchBookOverview({
    required int bookId,
    String? token,
  }) async {
    if (bookId <= 0) {
      return ApiResponse(success: false, message: 'Invalid bookId.');
    }
    final resolvedToken = await _resolveToken(token);
    if (resolvedToken == null) {
      return ApiResponse(success: false, message: 'Missing auth token. Please login again.');
    }

    final uri = _uri('/teacher/books/$bookId');

    try {
      if (kDebugMode) debugPrint('📡 GET $uri');
      final res = await http.get(uri, headers: _headers(resolvedToken));
      final body = jsonDecode(res.body.isEmpty ? '{}' : res.body);

      if (kDebugMode) {
        debugPrint('🧾 Status: ${res.statusCode}');
        debugPrint('🧾 Body: $body');
      }

      if (res.statusCode == 200 && body is Map && body['success'] == true) {
        return ApiResponse(
          success: true,
          data: {
            'book': _asStringMap(body['book']),
            'tags': (body['tags'] is List) ? List<String>.from(body['tags']) : <String>[],
            'grades': _asListOfStringMap(body['grades']),
            'courses': _asListOfStringMap(body['courses']),
            'subject_links': _asListOfStringMap(body['subject_links']),
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

  /// GET /api/flutter/teacher/books/{id}/students
  /// (Enable this route in Laravel if you plan to use it)
  static Future<ApiResponse<Map<String, dynamic>>> fetchBookStudents({
    required int bookId,
    String? token,
  }) async {
    if (bookId <= 0) {
      return ApiResponse(success: false, message: 'Invalid bookId.');
    }
    final resolvedToken = await _resolveToken(token);
    if (resolvedToken == null) {
      return ApiResponse(success: false, message: 'Missing auth token. Please login again.');
    }

    final uri = _uri('/teacher/books/$bookId/students');

    try {
      if (kDebugMode) debugPrint('📡 GET $uri');
      final res = await http.get(uri, headers: _headers(resolvedToken));
      final body = jsonDecode(res.body.isEmpty ? '{}' : res.body);

      if (kDebugMode) {
        debugPrint('🧾 Status: ${res.statusCode}');
        debugPrint('🧾 Body: $body');
      }

      if (res.statusCode == 200 && body is Map && body['success'] == true) {
        final subjects = _asListOfStringMap(body['subjects']);
        return ApiResponse(success: true, data: {'subjects': subjects});
      }

      final msg = (body is Map && body['message'] != null)
          ? body['message'].toString()
          : 'Fetch failed (${res.statusCode})';
      return ApiResponse(success: false, message: msg);
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  /// POST /api/flutter/teacher/books/assessment-management
  /// Body: { "bookID": <int> }
  static Future<ApiResponse<Map<String, dynamic>>> fetchAssessmentManagement({
    required int bookId,
    String? token,
  }) async {
    if (bookId <= 0) {
      return ApiResponse(success: false, message: 'Invalid bookId.');
    }
    final resolvedToken = await _resolveToken(token);
    if (resolvedToken == null) {
      return ApiResponse(success: false, message: 'Missing auth token. Please login again.');
    }

    final uri = _uri('/teacher/books/assessment-management');

    try {
      if (kDebugMode) debugPrint('📡 POST $uri {bookID: $bookId}');
      final res = await http.post(
        uri,
        headers: {
          ..._headers(resolvedToken),
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'bookID': bookId}),
      );

      final body = jsonDecode(res.body.isEmpty ? '{}' : res.body);

      if (kDebugMode) {
        debugPrint('🧾 Status: ${res.statusCode}');
        debugPrint('🧾 Body: $body');
      }

      if (res.statusCode == 200 && body is Map && body['success'] == true) {
        // { assessments: { "Section A": [...], "Section B": [...] } }
        final assessments = _asStringMap(body['assessments']);
        return ApiResponse(success: true, data: {'assessments': assessments});
      }

      final msg = (body is Map && body['message'] != null)
          ? body['message'].toString()
          : 'Fetch failed (${res.statusCode})';
      return ApiResponse(success: false, message: msg);
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  /// POST /api/flutter/teacher/books/grade-percentage-assessment
  /// Body: { "subjectID": <int> }
  static Future<ApiResponse<Map<String, dynamic>>> fetchGradePercentageAssessment({
    required int subjectId,
    String? token,
  }) async {
    if (subjectId <= 0) {
      return ApiResponse(success: false, message: 'Invalid subjectId.');
    }
    final resolvedToken = await _resolveToken(token);
    if (resolvedToken == null) {
      return ApiResponse(success: false, message: 'Missing auth token. Please login again.');
    }

    final uri = _uri('/teacher/books/grade-percentage-assessment');

    try {
      if (kDebugMode) debugPrint('📡 POST $uri {subjectID: $subjectId}');
      final res = await http.post(
        uri,
        headers: {
          ..._headers(resolvedToken),
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'subjectID': subjectId}),
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
            'grade_percentage': _asListOfStringMap(body['grade_percentage']),
            'unformatted_assessments': _asListOfStringMap(body['unformatted_assessments']),
            'quarter': _asListOfStringMap(body['quarter']),
            'unassigned_assessments': _asListOfStringMap(body['unassigned_assessments']),
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
