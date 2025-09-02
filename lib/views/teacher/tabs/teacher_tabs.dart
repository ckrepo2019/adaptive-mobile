// lib/views/student/tabs/student_tabs.dart
import 'package:flutter/widgets.dart';

class TeacherTabs extends InheritedWidget {
  final int index;
  final void Function(int) setIndex;

  const TeacherTabs({
    super.key,
    required this.index,
    required this.setIndex,
    required super.child,
  });

  static TeacherTabs of(BuildContext context) {
    final TeacherTabs? result = context
        .dependOnInheritedWidgetOfExactType<TeacherTabs>();
    assert(result != null, 'TeacherTabs not found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(TeacherTabs oldWidget) =>
      index != oldWidget.index || setIndex != oldWidget.setIndex;
}
