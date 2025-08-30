import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_lms/config/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

class StudentSubjectController {
  static Future<String?> _resolveToken(String? token) async {
    if (token != null && token.isNotEmpty) return token;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static _JsonParseResult parseServerJson(http.Response res) {
    if (res.statusCode == 204 || res.bodyBytes.isEmpty) {
      return _JsonParseResult(
        statusCode: res.statusCode,
        cleanedText: '[]',
        json: const [],
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

  static Future<ApiResponse<List<Map<String, dynamic>>>>
  fetchAllFirstLevelContents({required int subjectId, String? token}) async {
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

    final uri = Uri.parse(
      '${AppConstants.baseURL}/get-student-subject-firstlevel-contents/$subjectId',
    );

    try {
      final res = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $resolvedToken',
        },
      );

      final parsed = parseServerJson(res);

      if (res.statusCode != 200) {
        if (parsed.ok &&
            parsed.json is Map &&
            (parsed.json['message'] != null)) {
          return ApiResponse(
            success: false,
            message: parsed.json['message'].toString(),
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

      final decoded = parsed.json;
      if (decoded is List) {
        final items = decoded
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        return ApiResponse(success: true, data: items);
      }
      if (decoded is Map && decoded['data'] is List) {
        final items = (decoded['data'] as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        return ApiResponse(success: true, data: items);
      }

      return ApiResponse(
        success: false,
        message: 'Unexpected JSON shape from server.',
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  static Future<ApiResponse<String>> fetchBookUnitContentRaw({
    required int bookId,
    required int parentId,
    required int subjectId,
    String? token,
  }) async {
    if (bookId <= 0 || parentId <= 0 || subjectId <= 0) {
      return ApiResponse(success: false, message: 'Invalid ids.');
    }

    final resolvedToken = await _resolveToken(token);
    if (resolvedToken == null) {
      return ApiResponse(
        success: false,
        message: 'Missing auth token. Pass token or login first.',
      );
    }

    final uri = Uri.parse(
      '${AppConstants.baseURL}/student/book-unitcontent/$bookId/$parentId/$subjectId',
    );

    try {
      final headers = <String, String>{
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'Authorization': 'Bearer $resolvedToken',
      };

      final res = await http.get(uri, headers: headers);

      final parsed = parseServerJson(res);

      if (res.statusCode != 200) {
        if (parsed.ok && parsed.json is Map && parsed.json['message'] != null) {
          return ApiResponse(
            success: false,
            message: 'HTTP ${res.statusCode} — ${parsed.json['message']}',
          );
        }
        final preview = parsed.cleanedText.length > 400
            ? '${parsed.cleanedText.substring(0, 400)}…'
            : parsed.cleanedText;
        return ApiResponse(
          success: false,
          message: 'HTTP ${res.statusCode} — $preview',
        );
      }

      if (!parsed.ok) {
        return ApiResponse(success: false, message: parsed.error!);
      }

      return ApiResponse(success: true, data: parsed.cleanedText);
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  static Future<ApiResponse<String>> fetchBookTreeByContentRaw({
    required int bookId,
    required int subjectId,
    required int bookcontentId,
    String? token,
    int attempts = 4,
    Duration pause = const Duration(milliseconds: 600),
  }) async {
    if (bookId <= 0 || subjectId <= 0 || bookcontentId <= 0) {
      return ApiResponse(success: false, message: 'Invalid ids.');
    }

    final resolvedToken = await _resolveToken(token);
    if (resolvedToken == null) {
      return ApiResponse(
        success: false,
        message: 'Missing auth token. Pass token or login first.',
      );
    }

    bool _looksIncomplete(dynamic json, String cleaned) {
      if (cleaned.trim().isEmpty ||
          cleaned.trim() == '[]' ||
          cleaned.length < 8) {
        return true;
      }

      if (json is List) {
        if (json.isEmpty) return true;
        final first = json.first;
        if (first is Map) {
          final content = first['content'];
          final children = first['children'];
          if (content is Map) {
            final l2 = content['level2_count'];
            final l2Count = (l2 is num)
                ? l2.toInt()
                : int.tryParse('${l2 ?? ''}') ?? 0;
            if (children is List) {
              if (children.isEmpty && l2Count > 0) return true;
            }
          }
        }
        return false;
      }

      if (json is Map) {
        final children = json['children'];
        if (children is List && children.isEmpty) return true;
        return false;
      }

      return false;
    }

    for (int attempt = 0; attempt < attempts; attempt++) {
      final cacheBuster = attempt == 0
          ? null
          : {'_': DateTime.now().millisecondsSinceEpoch.toString()};

      final uri = Uri.parse(
        '${AppConstants.baseURL}/student/book/$bookId/subject/$subjectId/content/$bookcontentId/tree',
      ).replace(queryParameters: cacheBuster);

      try {
        final headers = <String, String>{
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
          'Authorization': 'Bearer $resolvedToken',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
          'Expires': '0',
        };

        final res = await http
            .get(uri, headers: headers)
            .timeout(const Duration(seconds: 25));
        final parsed = parseServerJson(res);

        if (res.statusCode != 200) {
          if (parsed.ok &&
              parsed.json is Map &&
              parsed.json['message'] != null) {
            return ApiResponse(
              success: false,
              message: 'HTTP ${res.statusCode} — ${parsed.json['message']}',
            );
          }
          final preview = parsed.cleanedText.length > 400
              ? '${parsed.cleanedText.substring(0, 400)}…'
              : parsed.cleanedText;
          return ApiResponse(
            success: false,
            message: 'HTTP ${res.statusCode} — $preview',
          );
        }

        if (!parsed.ok) {
          if (attempt < attempts - 1) {
            await Future.delayed(pause);
            continue;
          }
          return ApiResponse(success: false, message: parsed.error!);
        }

        if (_looksIncomplete(parsed.json, parsed.cleanedText)) {
          if (attempt < attempts - 1) {
            await Future.delayed(pause);
            continue;
          }
          return ApiResponse(
            success: false,
            message:
                'Received empty/incomplete content tree after $attempts attempts.',
          );
        }

        return ApiResponse(success: true, data: parsed.cleanedText);
      } on TimeoutException {
        if (attempt < attempts - 1) {
          await Future.delayed(pause);
          continue;
        }
        return ApiResponse(success: false, message: 'Request timed out.');
      } catch (e) {
        if (attempt < attempts - 1) {
          await Future.delayed(pause);
          continue;
        }
        return ApiResponse(success: false, message: 'Network error: $e');
      }
    }

    return ApiResponse(success: false, message: 'Unexpected error.');
  }

  static Future<ApiResponse<Map<String, dynamic>>> fetchAssessmentDetails({
    required int teacherAssessmentId,
    String? token,
  }) async {
    if (teacherAssessmentId <= 0) {
      return ApiResponse(
        success: false,
        message: 'Invalid teacherAssessmentId.',
      );
    }

    final resolvedToken = await _resolveToken(token);
    if (resolvedToken == null) {
      return ApiResponse(
        success: false,
        message: 'Missing auth token. Pass token or login first.',
      );
    }

    final uri = Uri.parse(
      '${AppConstants.baseURL}/student/assessment/$teacherAssessmentId',
    );

    try {
      final res = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $resolvedToken',
        },
      );

      final parsed = parseServerJson(res);

      if (res.statusCode != 200) {
        if (parsed.ok && parsed.json is Map && parsed.json['message'] != null) {
          return ApiResponse(
            success: false,
            message: 'HTTP ${res.statusCode} — ${parsed.json['message']}',
          );
        }
        return ApiResponse(
          success: false,
          message: 'Failed with status ${res.statusCode}',
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

      final data = Map<String, dynamic>.from(parsed.json);
      return ApiResponse(success: true, data: data);
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> submitAssessment({
    required int assessmentId,
    required List<Map<String, dynamic>> answers,
    String? token,
  }) async {
    if (assessmentId <= 0) {
      return ApiResponse(success: false, message: 'Invalid assessmentId.');
    }

    final resolvedToken = await _resolveToken(token);
    if (resolvedToken == null) {
      return ApiResponse(
        success: false,
        message: 'Missing auth token. Pass token or login first.',
      );
    }
    print(resolvedToken);

    final uri = Uri.parse('${AppConstants.baseURL}/student/assessment/submit');

    final payload = <String, dynamic>{
      'assessmentID': assessmentId,
      'answers': answers,
    };

    try {
      final res = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $resolvedToken',
        },
        body: jsonEncode(payload),
      );

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
          message: 'Submit failed (${res.statusCode}).',
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

      final data = Map<String, dynamic>.from(parsed.json);
      return ApiResponse(success: true, data: data);
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> saveChoice({
    required int assessmentId,
    required int questionId,
    required String questionType,
    int? choiceId,
    bool? isSelected,
    String? answerText,
    String? token,
  }) async {
    if (assessmentId <= 0 || questionId <= 0 || questionType.trim().isEmpty) {
      return ApiResponse(success: false, message: 'Invalid inputs.');
    }

    final resolvedToken = await _resolveToken(token);
    if (resolvedToken == null) {
      return ApiResponse(success: false, message: 'Missing auth token.');
    }

    final uri = Uri.parse('${AppConstants.baseURL}/assessment/save-choice');

    final payload = <String, dynamic>{
      'assessmentID': assessmentId,
      'questionId': questionId,
      'questionType': questionType,
      if (choiceId != null) 'choiceId': choiceId,
      if (isSelected != null) 'isSelected': isSelected.toString(),
      if (answerText != null) 'answerText': answerText,
    };

    try {
      final res = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $resolvedToken',
        },
        body: jsonEncode(payload),
      );

      final parsed = parseServerJson(res);
      if (res.statusCode != 200) {
        if (parsed.ok && parsed.json is Map && parsed.json['message'] != null) {
          return ApiResponse(
            success: false,
            message: 'HTTP ${res.statusCode} — ${parsed.json['message']}',
          );
        }
        return ApiResponse(
          success: false,
          message: 'Failed with status ${res.statusCode}.',
        );
      }
      if (!parsed.ok || parsed.json is! Map) {
        return ApiResponse(
          success: false,
          message: parsed.error ?? 'Unexpected JSON shape.',
        );
      }
      return ApiResponse(
        success: true,
        data: Map<String, dynamic>.from(parsed.json),
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  static Future<ApiResponse<List<Map<String, dynamic>>>> getUserAnswers({
    required int assessmentId,
    String? token,
  }) async {
    if (assessmentId <= 0) {
      return ApiResponse(success: false, message: 'Invalid assessmentId.');
    }

    final resolvedToken = await _resolveToken(token);
    if (resolvedToken == null) {
      return ApiResponse(success: false, message: 'Missing auth token.');
    }

    final uri = Uri.parse(
      '${AppConstants.baseURL}/assessment/answers?assessmentID=$assessmentId',
    );

    try {
      final res = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $resolvedToken',
        },
      );

      final parsed = parseServerJson(res);

      if (res.statusCode != 200) {
        if (parsed.ok && parsed.json is Map && parsed.json['message'] != null) {
          return ApiResponse(
            success: false,
            message: 'HTTP ${res.statusCode} — ${parsed.json['message']}',
          );
        }
        return ApiResponse(
          success: false,
          message: 'Failed with status ${res.statusCode}',
        );
      }

      if (!parsed.ok || parsed.json is! Map) {
        return ApiResponse(
          success: false,
          message: parsed.error ?? 'Unexpected JSON.',
        );
      }

      final map = Map<String, dynamic>.from(parsed.json);
      final answers = (map['answers'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      return ApiResponse(success: true, data: answers);
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> startAssessmentTimer({
    required int assessmentId,
    required int timeLimitSeconds,
    String? token,
  }) async {
    if (assessmentId <= 0 || timeLimitSeconds < 0) {
      return ApiResponse(success: false, message: 'Invalid inputs.');
    }

    final resolvedToken = await _resolveToken(token);
    if (resolvedToken == null) {
      return ApiResponse(success: false, message: 'Missing auth token.');
    }

    final uri = Uri.parse('${AppConstants.baseURL}/assessment/start-time');
    final payload = {
      'assessmentID': assessmentId,
      'timeLimit': timeLimitSeconds,
    };

    try {
      final res = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $resolvedToken',
        },
        body: jsonEncode(payload),
      );

      final parsed = parseServerJson(res);
      if (res.statusCode != 200) {
        if (parsed.ok && parsed.json is Map && parsed.json['message'] != null) {
          return ApiResponse(
            success: false,
            message: 'HTTP ${res.statusCode} — ${parsed.json['message']}',
          );
        }
        return ApiResponse(
          success: false,
          message: 'Failed with status ${res.statusCode}.',
        );
      }
      if (!parsed.ok || parsed.json is! Map) {
        return ApiResponse(
          success: false,
          message: parsed.error ?? 'Unexpected JSON.',
        );
      }
      return ApiResponse(
        success: true,
        data: Map<String, dynamic>.from(parsed.json),
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> getRemainingTime({
    required int assessmentId,
    String? token,
  }) async {
    if (assessmentId <= 0) {
      return ApiResponse(success: false, message: 'Invalid assessmentId.');
    }

    final resolvedToken = await _resolveToken(token);
    if (resolvedToken == null) {
      return ApiResponse(success: false, message: 'Missing auth token.');
    }

    final uri = Uri.parse(
      '${AppConstants.baseURL}/assessment/time-left?assessmentID=$assessmentId',
    );

    try {
      final res = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $resolvedToken',
        },
      );

      final parsed = parseServerJson(res);
      if (res.statusCode != 200) {
        if (parsed.ok && parsed.json is Map && parsed.json['message'] != null) {
          return ApiResponse(
            success: false,
            message: 'HTTP ${res.statusCode} — ${parsed.json['message']}',
          );
        }
        return ApiResponse(
          success: false,
          message: 'Failed with status ${res.statusCode}',
        );
      }

      if (!parsed.ok || parsed.json is! Map) {
        return ApiResponse(
          success: false,
          message: parsed.error ?? 'Unexpected JSON.',
        );
      }

      final map = Map<String, dynamic>.from(parsed.json);
      return ApiResponse(success: true, data: map);
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> updateTimeLeft({
    required int assessmentId,
    required int timeLeftSeconds,
    String? token,
  }) async {
    if (assessmentId <= 0 || timeLeftSeconds < 0) {
      return ApiResponse(success: false, message: 'Invalid inputs.');
    }

    final resolvedToken = await _resolveToken(token);
    if (resolvedToken == null) {
      return ApiResponse(success: false, message: 'Missing auth token.');
    }

    final uri = Uri.parse('${AppConstants.baseURL}/assessment/update-time');
    final payload = {
      'assessmentID': assessmentId,
      'time_left': timeLeftSeconds,
    };

    try {
      final res = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $resolvedToken',
        },
        body: jsonEncode(payload),
      );

      final parsed = parseServerJson(res);
      if (res.statusCode != 200) {
        if (parsed.ok && parsed.json is Map && parsed.json['message'] != null) {
          return ApiResponse(
            success: false,
            message: 'HTTP ${res.statusCode} — ${parsed.json['message']}',
          );
        }
        return ApiResponse(
          success: false,
          message: 'Failed with status ${res.statusCode}.',
        );
      }
      if (!parsed.ok || parsed.json is! Map) {
        return ApiResponse(
          success: false,
          message: parsed.error ?? 'Unexpected JSON.',
        );
      }
      return ApiResponse(
        success: true,
        data: Map<String, dynamic>.from(parsed.json),
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  static Future<ApiResponse<List<Map<String, dynamic>>>> fetchStudentRubric({
    required int rubricId,
    String? token,
  }) async {
    if (rubricId <= 0) {
      return ApiResponse(success: false, message: 'Invalid rubricId.');
    }

    final resolvedToken = await _resolveToken(token);
    if (resolvedToken == null) {
      return ApiResponse(success: false, message: 'Missing auth token.');
    }

    final uri = Uri.parse(
      '${AppConstants.baseURL}/student/rubric?rubricID=$rubricId',
    );

    try {
      final res = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $resolvedToken',
        },
      );

      final parsed = parseServerJson(res);

      if (res.statusCode != 200) {
        if (parsed.ok && parsed.json is Map && parsed.json['message'] != null) {
          return ApiResponse(
            success: false,
            message: 'HTTP ${res.statusCode} — ${parsed.json['message']}',
          );
        }
        return ApiResponse(
          success: false,
          message: 'Failed with status ${res.statusCode}',
        );
      }

      if (!parsed.ok) {
        return ApiResponse(success: false, message: parsed.error!);
      }

      if (parsed.json is! List) {
        return ApiResponse(
          success: false,
          message: 'Unexpected JSON shape (expected list).',
        );
      }

      final items = (parsed.json as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      return ApiResponse(success: true, data: items);
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }
}
