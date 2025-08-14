import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import 'api_response.dart';

class AuthController {
  static Future<ApiResponse<Map<String, dynamic>>> login({
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse('${AppConstants.baseURL}/login');

    try {
      final res = await http.post(
        uri,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username.trim(),
          'password': password.trim(),
        }),
      );

      final body = jsonDecode(res.body);

      print(body);

      if (res.statusCode == 200 && body['success'] == true) {
        return ApiResponse(
          success: true,
          data: {
            'token': body['token'],
            'id': body['data']['id'],
            'uid': body['data']['uid'],
            'user_type': body['data']['user_type'],
          },
        );
      }

      return ApiResponse(
        success: false,
        message: body is Map && body['message'] != null
            ? body['message'].toString()
            : 'Login failed (${res.statusCode})',
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }
}
