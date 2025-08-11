import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import 'api_response.dart';

class UserController {
  static Future<ApiResponse<Map<String, dynamic>>> getUser({
    required String token,
    required String uid,
    required int userType,
  }) async {
    final uri = Uri.parse(
      '${AppConstants.baseURL}/get-user/$uid?usertype_ID=$userType',
    );

    try {
      final res = await http
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 20));

      // Try parse body even on non-200 for meaningful message
      Map<String, dynamic>? parsed;
      try {
        final raw = jsonDecode(res.body);
        if (raw is Map<String, dynamic>) parsed = raw;
      } catch (_) {}

      if (res.statusCode == 200 && (parsed?['success'] == true)) {
        final data = Map<String, dynamic>.from(parsed!['data'] as Map);
        return ApiResponse(success: true, data: data);
      }

      // Handle common auth errors cleanly
      if (res.statusCode == 401) {
        return ApiResponse(
          success: false,
          message: parsed?['message']?.toString() ?? 'Unauthorized (401).',
        );
      }

      return ApiResponse(
        success: false,
        message:
            parsed?['message']?.toString() ??
            'Fetch failed (${res.statusCode}).',
      );
    } on SocketException catch (e) {
      return ApiResponse(success: false, message: 'No internet connection: $e');
    } on HttpException catch (e) {
      return ApiResponse(success: false, message: 'HTTP error: $e');
    } on FormatException catch (e) {
      return ApiResponse(success: false, message: 'Bad response format: $e');
    } on TimeoutException {
      return ApiResponse(success: false, message: 'Request timed out.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Unexpected error: $e');
    }
  }
}
