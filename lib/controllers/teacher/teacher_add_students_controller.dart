import 'dart:convert';
import 'package:Adaptive/config/constants.dart';
import 'package:Adaptive/controllers/api_response.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TeacherAddStudentsController {
  /// 🔎 Look up a student by their SID
  static Future<ApiResponse<Map<String, dynamic>>> getStudentBySid({
    required String sid,
    String? token,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = token ?? prefs.getString('token');
      if (authToken == null) {
        return ApiResponse(success: false, message: 'Missing token');
      }

      // ✅ Use the correct backend route
      final uri = Uri.parse('${AppConstants.baseURL}/teacher/students/$sid');
      if (kDebugMode) debugPrint('📡 GET $uri');

      final res = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      final data = jsonDecode(res.body.isEmpty ? '{}' : res.body);

      if (res.statusCode == 200 && data['success'] == true) {
        return ApiResponse(success: true, data: data['student']);
      }
      return ApiResponse(
        success: false,
        message: data['message'] ??
            (res.statusCode == 404 ? 'Student not found' : 'Unexpected error'),
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  /// ➕ Add multiple students to a subject/section
  static Future<ApiResponse<Map<String, dynamic>>> addStudents({
    required List<int> studentIds,
    required int subjectId,
    required int sectionId,
    String? token,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = token ?? prefs.getString('token');
      if (authToken == null) {
        return ApiResponse(success: false, message: 'Missing token');
      }

      final uri = Uri.parse('${AppConstants.baseURL}/teacher/add-students');
      final body = jsonEncode({
        'student_ID': studentIds,
        'subject_ID': subjectId,
        'sectionID': sectionId,
      });

      if (kDebugMode) {
        debugPrint('📡 POST $uri');
        debugPrint('Payload: $body');
      }

      final res = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: body,
      );

      final data = jsonDecode(res.body.isEmpty ? '{}' : res.body);

      if (kDebugMode) {
        debugPrint('Status: ${res.statusCode}');
        debugPrint('Response: $data');
      }

      if (res.statusCode == 200 && data['success'] == true) {
        return ApiResponse(success: true, data: data);
      }
      return ApiResponse(
        success: false,
        message: data['message'] ?? 'Failed to add students',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: $e',
      );
    }
  }
}
