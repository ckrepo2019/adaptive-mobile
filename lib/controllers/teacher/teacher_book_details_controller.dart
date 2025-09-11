import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_lms/config/constants.dart';
import 'package:flutter_lms/controllers/api_response.dart';

class TeacherBookDetailsController {
  /// ✅ Resolve token from SharedPreferences if not provided explicitly
  static Future<String?> _resolveToken(String? token) async {
    if (token != null && token.isNotEmpty) return token;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// ✅ Utility: Safe cast to Map<String, dynamic>
  static Map<String, dynamic> _asStringMap(dynamic v) {
    if (v is Map) {
      return v.map((k, val) => MapEntry(k.toString(), val));
    }
    return <String, dynamic>{};
  }

  /// ✅ Utility: Safe cast to list of maps
  static List<Map<String, dynamic>> _asListOfStringMap(dynamic v) {
    if (v is List) {
      return v
          .where((e) => e is Map)
          .map((e) => (e as Map).map((k, val) => MapEntry(k.toString(), val)))
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  /// 📚 Fetch book details by ID
  ///
  /// Calls: GET /api/flutter/teacher/books/{bookId}
  /// Returns: { book, tags[], grades[], courses[], subjects[] }
  static Future<ApiResponse<Map<String, dynamic>>> fetchBookDetails({
    required int bookId,
    String? token,
  }) async {
    if (bookId <= 0) {
      return ApiResponse(
        success: false,
        message: 'Invalid bookId.',
      );
    }

    final resolvedToken = await _resolveToken(token);
    if (resolvedToken == null) {
      return ApiResponse(
        success: false,
        message: 'Missing auth token. Please login again.',
      );
    }

    final url = '${AppConstants.baseURL}/teacher/books/$bookId';

    try {
      if (kDebugMode) debugPrint('📡 GET $url');
      final res = await http.get(
        Uri.parse(url),
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
        final book = _asStringMap(body['book']);
        final tags = (body['tags'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList();
        final grades = (body['grades'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList();
        final courses = (body['courses'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList();
        final subjects = _asListOfStringMap(body['subjects']);

        return ApiResponse(
          success: true,
          data: {
            'book': book,
            'tags': tags,
            'grades': grades,
            'courses': courses,
            'subjects': subjects,
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
