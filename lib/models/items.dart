import 'package:flutter/material.dart';

/// Assignment item model
class AssignmentItem {
  final String title;
  final String subject;
  final String date;
  final String duration;
  final String type;
  final String? description;

  const AssignmentItem({
    required this.title,
    required this.subject,
    required this.date,
    required this.duration,
    required this.type,
    this.description,
  });
}

/// Class progress item model
class ClassProgressItem {
  final String title;
  final int firstHierarchy;
  final int secondHierarchy;

  final String firstHierarchyLabel; // e.g., "Chapters"
  final String secondHierarchyLabel; // e.g., "Units"

  /// 0..1
  final double progress;
  final String iconAsset; // can be asset path OR http(s) URL
  final Color accent;

  const ClassProgressItem({
    required this.title,
    required this.firstHierarchy,
    required this.secondHierarchy,
    required this.firstHierarchyLabel,
    required this.secondHierarchyLabel,
    required this.progress,
    required this.iconAsset,
    this.accent = Colors.redAccent,
  });
}
