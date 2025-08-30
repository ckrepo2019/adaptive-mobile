import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_lms/config/constants.dart';
import '../api_response.dart';

class _JsonParseResult {
  final int statusCode;
  final dynamic json;
  final String cleanedText;
  final String? error;

  bool get ok => error == null;

  _JsonParseResult({
    required this.statusCode,
    required this.cleanedText,
    this.json,
    this.error,
  });
}

class StudentAssignmentController {
  static Future<String?> _resolveToken(String? token) async {
    if (token != null && token.isNotEmpty) return token;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static _JsonParseResult parseServerJson(http.Response res) {
    if (res.statusCode == 204 || res.bodyBytes.isEmpty) {
      return _JsonParseResult(
        statusCode: res.statusCode,
        cleanedText: '{}',
        json: const <String, dynamic>{},
      );
    }

    String text = utf8.decode(res.bodyBytes, allowMalformed: true).trim();
    if (text.isNotEmpty && text.codeUnitAt(0) == 0xFEFF) {
      text = text.substring(1);
    }

    final cleaned = _extractLikelyJson(text);

    dynamic decoded;
    try {
      decoded = jsonDecode(cleaned);
      return _JsonParseResult(
        statusCode: res.statusCode,
        cleanedText: cleaned,
        json: decoded,
      );
    } catch (_) {
      final preview = cleaned.length > 200
          ? '${cleaned.substring(0, 200)}…'
          : cleaned;
      return _JsonParseResult(
        statusCode: res.statusCode,
        cleanedText: cleaned,
        error:
            'Invalid JSON from server (status ${res.statusCode}). Preview: $preview',
      );
    }
  }

  static String _extractLikelyJson(String raw) {
    String s = raw.trim();

    if ((s.startsWith('{') && s.endsWith('}')) ||
        (s.startsWith('[') && s.endsWith(']'))) {
      return s;
    }

    final firstBrace = s.indexOf('{');
    final firstBracket = s.indexOf('[');
    int start = -1;
    if (firstBrace != -1 && firstBracket != -1) {
      start = (firstBrace < firstBracket) ? firstBrace : firstBracket;
    } else {
      start = (firstBrace != -1) ? firstBrace : firstBracket;
    }
    if (start == -1) return s;

    final lastBrace = s.lastIndexOf('}');
    final lastBracket = s.lastIndexOf(']');
    int end = -1;
    if (lastBrace != -1 && lastBracket != -1) {
      end = (lastBrace > lastBracket) ? lastBrace : lastBracket;
    } else {
      end = (lastBrace != -1) ? lastBrace : lastBracket;
    }
    if (end == -1 || end <= start) return s;

    return s.substring(start, end + 1).trim();
  }

  static Future<ApiResponse<Map<String, dynamic>>> fetchAllAssessments({
    String? query,
    bool onlyOpen = false,
    bool pendingOnly = false,
    String order = 'latest',
    int page = 1,
    int perPage = 50,
    String? token,
    Duration timeout = const Duration(seconds: 25),
  }) async {
    final resolvedToken = await _resolveToken(token);
    if (resolvedToken == null) {
      return ApiResponse(success: false, message: 'Missing auth token.');
    }

    final qp = <String, String>{
      'order': order,
      'page': page.toString(),
      'per_page': perPage.toString(),
      if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
      if (onlyOpen) 'only_open': '1',
      if (pendingOnly) 'pending_only': '1',
    };

    final uri = Uri.parse(
      '${AppConstants.baseURL}/student/assessments',
    ).replace(queryParameters: qp);

    try {
      final res = await http
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $resolvedToken',
              'Cache-Control': 'no-cache, no-store, must-revalidate',
              'Pragma': 'no-cache',
              'Expires': '0',
            },
          )
          .timeout(timeout);

      final parsed = parseServerJson(res);

      if (res.statusCode != 200) {
        if (parsed.ok &&
            parsed.json is Map &&
            (parsed.json['message'] != null)) {
          return ApiResponse(
            success: false,
            message: 'HTTP ${res.statusCode} — ${parsed.json['message']}',
          );
        }
        return ApiResponse(
          success: false,
          message: 'Fetch failed (${res.statusCode})',
        );
      }

      if (!parsed.ok) {
        return ApiResponse(success: false, message: parsed.error!);
      }

      if (parsed.json is! Map) {
        return ApiResponse(
          success: false,
          message: 'Unexpected JSON shape (expected object).',
        );
      }

      final data = Map<String, dynamic>.from(parsed.json as Map);
      return ApiResponse(success: true, data: data);
    } on TimeoutException {
      return ApiResponse(success: false, message: 'Request timed out.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  static Future<ApiResponse<List<Map<String, dynamic>>>> fetchPending({
    String? query,
    int page = 1,
    int perPage = 50,
    String? token,
  }) async {
    final resp = await fetchAllAssessments(
      query: query,
      pendingOnly: true,
      page: page,
      perPage: perPage,
      token: token,
    );
    if (!resp.success) {
      return ApiResponse(success: false, message: resp.message);
    }

    final list = (resp.data?['assessments'] is List)
        ? (resp.data!['assessments'] as List)
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
        : <Map<String, dynamic>>[];

    return ApiResponse(success: true, data: list);
  }

  static Future<ApiResponse<List<Map<String, dynamic>>>> fetchOpen({
    String? query,
    int page = 1,
    int perPage = 50,
    String? token,
  }) async {
    final resp = await fetchAllAssessments(
      query: query,
      onlyOpen: true,
      page: page,
      perPage: perPage,
      token: token,
    );
    if (!resp.success) {
      return ApiResponse(success: false, message: resp.message);
    }

    final list = (resp.data?['assessments'] is List)
        ? (resp.data!['assessments'] as List)
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
        : <Map<String, dynamic>>[];

    return ApiResponse(success: true, data: list);
  }
}
