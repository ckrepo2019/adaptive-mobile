// lib/views/student/student_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_lms/views/student/classes/classes_page.dart';
import 'package:flutter_lms/views/student/home/home_page.dart';
import 'package:flutter_lms/views/student/widgets/fancy_student_navbar.dart';
import 'package:flutter_lms/views/student/tabs/student_tabs.dart';

class StudentShell extends StatefulWidget {
  final String token;
  final String uid;
  final int userType;

  const StudentShell({
    super.key,
    required this.token,
    required this.uid,
    required this.userType,
  });
  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _index = 0;

  void _setIndex(int i) {
    if (i == _index) return;
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    // Build pages AFTER we have the args (from widget)
    final pages = <Widget>[
      StudentHomePage(
        token: widget.token,
        uid: widget.uid,
        userType: widget.userType,
      ),
      StudentClassPage(),
      const ColoredBox(color: Colors.black12), // TODO: Schedule
      const ColoredBox(color: Colors.black12), // TODO: Notifications
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
            if (i == 0 || i == 1) return _setIndex(i);
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
