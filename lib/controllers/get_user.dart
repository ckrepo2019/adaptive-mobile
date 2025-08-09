import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import 'api_response.dart';

class UserController {
  static Future<ApiResponse<Map<String, dynamic>>> getUser({
    required String token,
    required int id,
    required int userType,
  }) async {
    final uri = Uri.parse(
      '${AppConstants.baseURL}/get-user/$id?usertype_ID=$userType',
    );

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
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          data: Map<String, dynamic>.from(body['data']),
        );
      }

      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: body is Map && body['message'] != null
            ? body['message'].toString()
            : 'Fetch failed (${res.statusCode})',
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Network error: $e',
      );
    }
  }
}
