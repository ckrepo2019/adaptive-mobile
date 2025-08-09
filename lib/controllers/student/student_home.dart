import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_lms/config/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_response.dart';

// fetch this to get the learner's_profile
// learner's profile == 0 && enrollment_data !== null
// intro page == show

class StudentHomeController {
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
        // body['data'] is a JSON object with all sub-sections
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
    required List<Map<String, dynamic>>
    responses, // {question_id, question_number, answer}
    required List<int> favoriteSubjects,
    required List<int> hobbies,
    String? anythingElse,
  }) async {
    // Resolve token from SharedPreferences if not provided
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
          'favoriteSubjects': favoriteSubjects,
          'hobbies': hobbies,
          'anythingElse': anythingElse,
        }),
      );

      final body = jsonDecode(res.body);

      if (res.statusCode == 200 && body['success'] == true) {
        // sample return: { success, message, data: { studentID, syID, learnerassessmentID, learningStyleIDs } }
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

  static Future<String?> _resolveToken(String? token) async {
    if (token != null && token.isNotEmpty) return token;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
