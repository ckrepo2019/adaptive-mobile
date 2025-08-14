import 'package:flutter/material.dart';
import 'package:flutter_lms/views/student/home/home_page.dart';
import 'widgets/fancy_student_navbar.dart';

class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _index = 0;

  final _pages = const [
    StudentHomePage(),
    ColoredBox(color: Colors.black12), // TODO replace with Analytics()
    ColoredBox(color: Colors.black12), // TODO replace with Schedule()
    ColoredBox(color: Colors.black12), // TODO replace with Notifications()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2F2F2F),
      body: _pages[_index],
      bottomNavigationBar: FancyStudentNavBar(
        currentIndex: _index,
        onChanged: (i) => setState(() => _index = i),
        items: const [
          NavItem(icon: Icons.home_rounded),
          NavItem(icon: Icons.pie_chart_rounded),
          NavItem(icon: Icons.access_time_rounded),
          NavItem(icon: Icons.notifications_rounded),
        ],
      ),
    );
  }
}
