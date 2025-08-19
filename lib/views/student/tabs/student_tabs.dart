// lib/views/student/tabs/student_tabs.dart
import 'package:flutter/widgets.dart';

class StudentTabs extends InheritedWidget {
  final int index;
  final void Function(int) setIndex;

  const StudentTabs({
    super.key,
    required this.index,
    required this.setIndex,
    required super.child,
  });

  static StudentTabs of(BuildContext context) {
    final StudentTabs? result = context
        .dependOnInheritedWidgetOfExactType<StudentTabs>();
    assert(result != null, 'StudentTabs not found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(StudentTabs oldWidget) =>
      index != oldWidget.index || setIndex != oldWidget.setIndex;
}
