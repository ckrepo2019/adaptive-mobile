import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_lms/config/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_response.dart';

class StudentHomeController {
  static Future<String?> _resolveToken(String? token) async {
    if (token != null && token.isNotEmpty) return token;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<ApiResponse<Map<String, dynamic>>> fetchStudentHome({
    required String token,
    required String uid,
  }) async {
    final uri = Uri.parse('${AppConstants.baseURL}/student-home/$uid');

    try {
      final res = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final body = jsonDecode(res.body);

      if (res.statusCode == 200 && body['success'] == true) {
        return ApiResponse(
          success: true,
          data: Map<String, dynamic>.from(body['data']),
        );
      }

      return ApiResponse(
        success: false,
        message: body is Map && body['message'] != null
            ? body['message'].toString()
            : 'Fetch failed (${res.statusCode})',
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> submitGetStarted({
    String? token,
    required int syID,
    required int learnerAssessmentID,
    required List<Map<String, dynamic>> responses,
    required List<int> hobbies,
  }) async {
    final resolvedToken = await _resolveToken(token);
    if (resolvedToken == null) {
      return ApiResponse(
        success: false,
        message:
            'Missing auth token. Pass token or login and save it to SharedPreferences.',
      );
    }

    final uri = Uri.parse('${AppConstants.baseURL}/submit-get-started');

    try {
      final res = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $resolvedToken',
        },
        body: jsonEncode({
          'syID': syID,
          'learnerassessmentID': learnerAssessmentID,
          'responses': responses,
          'hobbies': hobbies,
        }),
      );

      final body = jsonDecode(res.body);

      if (res.statusCode == 200 && body['success'] == true) {
        return ApiResponse(
          success: true,
          data: Map<String, dynamic>.from(body['data'] ?? {}),
        );
      }

      return ApiResponse(
        success: false,
        message: body is Map && body['message'] != null
            ? body['message'].toString()
            : 'Submit failed (${res.statusCode})',
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  static Future<ApiResponse<List<dynamic>>> fetchLearnerProfiles({
    String? token,
    int?
    studentId, // optional: if provided, backend will use this instead of auth user
  }) async {
    final resolvedToken = await _resolveToken(token);
    if (resolvedToken == null) {
      return ApiResponse(
        success: false,
        message: 'Missing auth token. Pass token or login first.',
      );
    }

    // If no studentId passed, try to get from SharedPreferences
    if (studentId == null) {
      final prefs = await SharedPreferences.getInstance();
      final storedId = prefs.getInt('id'); // assuming you store it as int
      if (storedId != null) {
        studentId = storedId;
      }
    }

    // Build URL with optional ?student_id=
    final base = '${AppConstants.baseURL}/get-learners-profile';
    final uri = Uri.parse(
      studentId == null ? base : '$base?student_id=$studentId',
    );

    try {
      final res = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $resolvedToken',
        },
      );

      final body = jsonDecode(res.body);

      // Backend: { success: bool, data: [...] }
      if (res.statusCode == 200 && body is Map && body['success'] == true) {
        final data = (body['data'] is List)
            ? List<dynamic>.from(body['data'])
            : <dynamic>[];
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
}
