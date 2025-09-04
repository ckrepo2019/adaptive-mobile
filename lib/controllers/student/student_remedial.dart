// lib/controllers/student/student_remedial.dart
import 'dart:convert';
import 'package:flutter_lms/config/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_response.dart';

class StudentRemedialController {
  // -------- helpers ----------
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

  static Map<String, String> _headers(String bearer) => {
    'Accept': 'application/json',
    'Authorization': 'Bearer $bearer',
  };

  // For JSON POSTs
  static Map<String, String> _jsonHeaders(String bearer) => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $bearer',
  };

  static dynamic _safeJson(String raw) {
    try {
      return raw.isEmpty ? {} : jsonDecode(raw);
    } catch (_) {
      return {};
    }
  }

  /// GET /student/remedial/mastery/{studentId}?teacherAssessmentID=###
  static Future<ApiResponse<Map<String, dynamic>>> fetchRemedialMastery({
    required int teacherAssessmentID,
    int? studentId,
    String? token,
  }) async {
    if (teacherAssessmentID <= 0) {
      return ApiResponse(
        success: false,
        message: 'Invalid teacherAssessmentID.',
      );
    }

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
            'Missing student id. Save it as "id" in SharedPreferences or pass studentId.',
      );
    }

    final base = '${AppConstants.baseURL}/student/remedial/mastery/$resolvedId';
    final uri = Uri.parse(base).replace(
      queryParameters: {'teacherAssessmentID': teacherAssessmentID.toString()},
    );

    try {
      final res = await http.get(uri, headers: _headers(resolvedToken));
      final body = _safeJson(res.body);

      if (res.statusCode == 200 && body is Map && body['success'] == true) {
        final Map<String, dynamic>? assessmentDetails =
            (body['assessment_details'] is Map)
            ? Map<String, dynamic>.from(body['assessment_details'])
            : null;

        final List<Map<String, dynamic>> learnersProfile =
            (body['learners_profile'] is List)
            ? List<Map<String, dynamic>>.from(
                (body['learners_profile'] as List).map(
                  (e) => (e is Map) ? Map<String, dynamic>.from(e) : {},
                ),
              )
            : <Map<String, dynamic>>[];

        return ApiResponse(
          success: true,
          data: {
            'assessment_details': assessmentDetails,
            'learners_profile': learnersProfile,
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

  /// GET /student/remedial/take/{studentId}?teacherAssessmentID=###&learners_type_id=###
  static Future<ApiResponse<Map<String, dynamic>>> fetchRemedialTake({
    required int teacherAssessmentID,
    required int learnersTypeId,
    int? studentId,
    String? token,
  }) async {
    if (teacherAssessmentID <= 0) {
      return ApiResponse(
        success: false,
        message: 'Invalid teacherAssessmentID.',
      );
    }
    if (learnersTypeId <= 0) {
      return ApiResponse(success: false, message: 'Invalid learners_type_id.');
    }

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
            'Missing student id. Save it as "id" in SharedPreferences or pass studentId.',
      );
    }

    final base = '${AppConstants.baseURL}/student/remedial/take/$resolvedId';
    final uri = Uri.parse(base).replace(
      queryParameters: {
        'teacherAssessmentID': teacherAssessmentID.toString(),
        'learners_type_id': learnersTypeId.toString(),
      },
    );

    try {
      final res = await http.get(uri, headers: _headers(resolvedToken));
      final body = _safeJson(res.body);

      if (res.statusCode == 200 && body is Map && body['success'] == true) {
        final Map<String, dynamic>? assessmentDetails =
            (body['assessment_details'] is Map)
            ? Map<String, dynamic>.from(body['assessment_details'])
            : null;

        final List<Map<String, dynamic>> wrongAnswers =
            (body['wrong_answers'] is List)
            ? List<Map<String, dynamic>>.from(
                (body['wrong_answers'] as List).map(
                  (e) => (e is Map) ? Map<String, dynamic>.from(e) : {},
                ),
              )
            : <Map<String, dynamic>>[];

        final List<Map<String, dynamic>> remedialQuestions =
            (body['remedial_questions'] is List)
            ? List<Map<String, dynamic>>.from(
                (body['remedial_questions'] as List).map(
                  (e) => (e is Map) ? Map<String, dynamic>.from(e) : {},
                ),
              )
            : <Map<String, dynamic>>[];

        final Map<String, dynamic>? learnersData =
            (body['learners_data'] is Map)
            ? Map<String, dynamic>.from(body['learners_data'])
            : null;

        final Map<String, dynamic>? enrolledDetails =
            (body['enrolled_details'] is Map)
            ? Map<String, dynamic>.from(body['enrolled_details'])
            : null;

        final List<Map<String, dynamic>> explanation =
            (body['explanation'] is List)
            ? List<Map<String, dynamic>>.from(
                (body['explanation'] as List).map(
                  (e) => (e is Map) ? Map<String, dynamic>.from(e) : {},
                ),
              )
            : <Map<String, dynamic>>[];

        return ApiResponse(
          success: true,
          data: {
            'assessment_details': assessmentDetails,
            'wrong_answers': wrongAnswers,
            'remedial_questions': remedialQuestions,
            'learners_data': learnersData,
            'enrolled_details': enrolledDetails,
            'explanation': explanation,
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

  /// POST /student/assessment/generate-explanation
  /// Body (JSON): { "assessmentID": 123 }
  /// Returns the Python script output when successful.
  static Future<ApiResponse<Map<String, dynamic>>> generateExplanation({
    required int assessmentID,
    String? token,
  }) async {
    if (assessmentID <= 0) {
      return ApiResponse(success: false, message: 'Invalid assessmentID.');
    }

    final resolvedToken = await _resolveToken(token);
    if (resolvedToken == null) {
      return ApiResponse(
        success: false,
        message: 'Missing auth token. Pass token or login first.',
      );
    }

    final uri = Uri.parse(
      '${AppConstants.baseURL}/student/assessment/generate-explanation',
    );

    try {
      final res = await http.post(
        uri,
        headers: _jsonHeaders(resolvedToken),
        body: jsonEncode({'assessmentID': assessmentID}),
      );

      final body = _safeJson(res.body);

      // success: true, output, message
      if (res.statusCode == 200 && body is Map && body['success'] == true) {
        return ApiResponse(
          success: true,
          data: {'message': body['message'], 'output': body['output']},
        );
      }

      // 4xx/5xx with message/error
      final msg = (body is Map && body['message'] != null)
          ? body['message'].toString()
          : 'Request failed (${res.statusCode})';

      return ApiResponse(
        success: false,
        message: msg,
        data: (body is Map) ? Map<String, dynamic>.from(body) : null,
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }
}
