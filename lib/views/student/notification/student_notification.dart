import 'package:flutter/material.dart';
import 'package:flutter_lms/views/utilities/layouts/global_layout.dart';
import 'package:flutter_lms/widgets/app_bar.dart';
import 'package:flutter_lms/widgets/cards_list.dart';
import 'package:flutter_lms/widgets/global_chip.dart';
import 'package:flutter_lms/widgets/skeleton_loader.dart';
import 'package:flutter_lms/models/items.dart';

class StudentNotificationPage extends StatefulWidget {
  const StudentNotificationPage({super.key});

  @override
  State<StudentNotificationPage> createState() =>
      _StudentNotificationPageState();
}

class _StudentNotificationPageState extends State<StudentNotificationPage> {
  bool _loading = true;
  String? _error;
  List<AssignmentItem> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    try {
      final List<AssignmentItem> mockAssignments = [
        AssignmentItem(
          title: "Math Quiz: Quadratic Equations",
          subject: "Mathematics",
          date: "March 20, 2025",
          duration: "20 min",
          type: "Quiz",
          assessment: const {},
          subjectData: const {},
          subjectIcon: "",
        ),
        AssignmentItem(
          title: "English Essay Review",
          subject: "English Language",
          date: "March 19, 2025",
          duration: "1h",
          type: "Assessment",
          assessment: const {},
          subjectData: const {},
          subjectIcon: "",
        ),
        AssignmentItem(
          title: "Biology Lab Report",
          subject: "Science",
          date: "March 18, 2025",
          duration: "45 min",
          type: "Assessment",
          assessment: const {},
          subjectData: const {},
          subjectIcon: "",
        ),
      ];
      setState(() {
        _notifications = mockAssignments;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load notifications';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return StudentGlobalLayout(
        useScaffold: false,
        header: const GlobalAppBar(title: 'Notifications'),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        useSafeArea: true,
        safeAreaTop: true,
        safeAreaBottom: true,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadNotifications,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    return SkeletonLoader(isLoading: _loading, child: _buildContent());
  }

  Widget _buildContent() {
    final w = MediaQuery.of(context).size.width;
    return StudentGlobalLayout(
      useScaffold: false,
      header: const GlobalAppBar(title: 'Notifications'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      useSafeArea: true,
      safeAreaTop: true,
      safeAreaBottom: true,
      onRefresh: _loadNotifications,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CustomChip(
                backgroundColor: Colors.black,
                textColor: Colors.white,
                borderColor: Colors.black54,
                chipTitle: 'Current',
                iconData: Icons.access_time,
              ),
              SizedBox(width: w * 0.02),
              const CustomChip(
                backgroundColor: Colors.white,
                textColor: Colors.black54,
                borderColor: Colors.black54,
                chipTitle: 'Read',
                iconData: Icons.archive_outlined,
              ),
            ],
          ),
          const SizedBox(height: 15),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  CardsList<AssignmentItem>(
                    items: _notifications,
                    variant: CardVariant.assignment,
                    onAssignmentTap: (a) {
                      debugPrint('Tapped: ${a.title}');
                    },
                  ),
                  const SizedBox(height: 96),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
