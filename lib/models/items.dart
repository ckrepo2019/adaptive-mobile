import 'package:flutter/material.dart';

/// Assignment item model
class AssignmentItem {
  final String title;
  final String subject;
  final String date;
  final String duration;
  final String type;
  final Map<String, dynamic> assessment;

  final Map<String, dynamic>? subjectData;
  final String? subjectIcon;

  AssignmentItem({
    required this.title,
    required this.subject,
    required this.date,
    required this.duration,
    required this.type,
    required this.assessment,
    this.subjectData,
    this.subjectIcon,
  });
}

class ClassProgressItem {
  final String title;
  final int firstHierarchy;
  final int secondHierarchy;
  final String firstHierarchyLabel;
  final String secondHierarchyLabel;
  final double progress;
  final String iconAsset;
  final Color accent;
  final Map<String, dynamic>? subject;

  ClassProgressItem({
    required this.title,
    required this.firstHierarchy,
    required this.secondHierarchy,
    required this.firstHierarchyLabel,
    required this.secondHierarchyLabel,
    required this.progress,
    required this.iconAsset,
    required this.accent,
    this.subject,
  });
}
