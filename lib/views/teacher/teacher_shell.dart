import 'package:flutter/material.dart';
import 'package:flutter_lms/views/student/widgets/fancy_student_navbar.dart';
import 'package:flutter_lms/views/teacher/tabs/teacher_tabs.dart';
import 'package:flutter_lms/views/teacher/home/home_page.dart';

class TeacherShell extends StatefulWidget {
  final String token;
  final String uid;
  final int userType;
  final int initialIndex;

  const TeacherShell({
    super.key,
    required this.token,
    required this.uid,
    required this.userType,
    this.initialIndex = 0,
  });

  @override
  State<TeacherShell> createState() => _TeacherShellState();
}

class _TeacherShellState extends State<TeacherShell>
    with TickerProviderStateMixin {
  late int _index;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.05), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _setIndex(int i) {
    if (i == _index) return;

    _animationController.reset();
    setState(() => _index = i);
    _animationController.forward();
  }

  Widget _buildAnimatedPage(Widget child) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, _) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(position: _slideAnimation, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      TeacherHomePage(
        token: widget.token,
        uid: widget.uid,
        userType: widget.userType,
      ),
    ];

    return TeacherTabs(
      index: _index,
      setIndex: _setIndex,
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBody: true,
        body: _buildAnimatedPage(
          IndexedStack(
            index: _index,
            children: pages
                .map((page) => KeyedSubtree(key: ValueKey(_index), child: page))
                .toList(),
          ),
        ),
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
