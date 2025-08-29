// lib/utils/nav_utils.dart
import 'package:flutter/material.dart';
import 'package:flutter_lms/config/routes.dart';

/// Navigation helpers shared across student pages.
class NavUtils {
  static int? handleStudentBottomNav({
    required BuildContext context,
    required int currentIndex,
    required int tappedIndex,
    String comingSoonMessage = 'Other tabs coming soon',
  }) {
    if (tappedIndex == currentIndex) return currentIndex;

    if (tappedIndex == 0) {
      return 0;
    }

    if (tappedIndex == 1) {
      Navigator.pushReplacementNamed(context, AppRoutes.studentClass);
      return null;
    }

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(comingSoonMessage),
        duration: const Duration(milliseconds: 900),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return null;
  }
}
