import 'package:flutter/material.dart';
import 'package:flutter_lms/config/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavigationUtils {
  /// Navigate back to StudentHome with required arguments
  static Future<void> goHomeWithArgs(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final uid = prefs.getString('uid');

    if (token == null || uid == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Missing credentials. Please sign in again.'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    if (!context.mounted) return;
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.studentHome,
      arguments: {'token': token, 'uid': uid, 'userType': 4},
    );
  }
}
