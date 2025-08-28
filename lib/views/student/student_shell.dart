// lib/views/student/student_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_lms/views/student/assignments/assignment_page.dart';
import 'package:flutter_lms/views/student/classes/classes_page.dart';
import 'package:flutter_lms/views/student/home/home_page.dart';
import 'package:flutter_lms/views/student/notification/student_notification.dart';
import 'package:flutter_lms/views/student/widgets/fancy_student_navbar.dart';
import 'package:flutter_lms/views/student/tabs/student_tabs.dart';

class StudentShell extends StatefulWidget {
  final String token;
  final String uid;
  final int userType;

  /// NEW: which tab to open first (0 = Home, 1 = Classes, 2 = Schedule, 3 = Notifications)
  final int initialIndex;

  const StudentShell({
    super.key,
    required this.token,
    required this.uid,
    required this.userType,
    this.initialIndex = 0, // default to Home
  });

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex; // ← start on requested tab
  }

  void _setIndex(int i) {
    if (i == _index) return;
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      StudentHomePage(
        token: widget.token,
        uid: widget.uid,
        userType: widget.userType,
      ),
      StudentClassPage(),
      StudentAssignmentPage(),
      StudentNotificationPage(),
    ];

    return StudentTabs(
      index: _index,
      setIndex: _setIndex,
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBody: true,
        body: IndexedStack(index: _index, children: pages),
        bottomNavigationBar: FancyStudentNavBar(
          currentIndex: _index,
          onChanged: (i) {
            if (i == 0 || i == 1 || i == 2 || i == 3) return _setIndex(i);
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Other tabs coming soon'),
                duration: Duration(milliseconds: 900),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          items: const [
            NavItem(icon: Icons.home_rounded),
            NavItem(icon: Icons.pie_chart_rounded),
            NavItem(icon: Icons.access_time_rounded),
            NavItem(icon: Icons.notifications_rounded),
          ],
        ),
      ),
    );
  }
}
