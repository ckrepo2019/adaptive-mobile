// lib/utils/nav_utils.dart
import 'package:flutter/material.dart';
import 'package:flutter_lms/config/routes.dart';

/// Navigation helpers shared across student pages.
class NavUtils {
  /// Handles bottom nav taps for the Student app.
  ///
  /// Returns:
  /// - An `int` to set as the new current index (when you should call setState)
  /// - `null` when this function already handled navigation or feedback
  ///   (e.g., pushed a route or showed a SnackBar), so caller should NOT setState.
  static int? handleStudentBottomNav({
    required BuildContext context,
    required int currentIndex,
    required int tappedIndex,
    String comingSoonMessage = 'Other tabs coming soon',
  }) {
    // No-op if reselecting the same tab
    if (tappedIndex == currentIndex) return currentIndex;

    // Home tab
    if (tappedIndex == 0) {
      return 0; // caller should setState(() => _index = 0)
    }

    // Classes tab -> navigate (replacement to feel like a tab)
    if (tappedIndex == 1) {
      Navigator.pushReplacementNamed(context, AppRoutes.studentClass);
      return null; // already navigated; don't setState here
    }

    // Other tabs -> show feedback
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(comingSoonMessage),
        duration: const Duration(milliseconds: 900),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return null; // no state change
  }
}
