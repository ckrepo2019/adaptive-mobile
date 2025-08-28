import 'package:flutter/material.dart';
import 'package:flutter_lms/views/student/student_global_layout.dart';
import 'package:flutter_lms/widgets/app_bar.dart';
import 'package:flutter_lms/widgets/cards_list.dart';
import 'package:flutter_lms/widgets/global_chip.dart';
import 'package:flutter_lms/models/items.dart';

class StudentNotificationPage extends StatelessWidget {
  const StudentNotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    // Static demo data
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

    return StudentGlobalLayout(
      // AppBar goes here (no Scaffold)
      useScaffold: false,
      header: const GlobalAppBar(title: 'Notifications'),

      // Page padding + safe areas
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      useSafeArea: true,
      safeAreaTop: true,
      safeAreaBottom: true,

      // Pull-to-refresh (optional) – add handler if you need it
      // onRefresh: () async { /* reload notifications */ },
      // forceScrollable: true, // if using onRefresh with non-scrollable child
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tabs (chips)
          Row(
            children: [
              CustomChip(
                backgroundColor: Colors.black,
                textColor: Colors.white,
                borderColor: Colors.black54,
                chipTitle: 'Current',
                iconData: Icons.access_time,
              ),
              SizedBox(width: w * 0.02),
              CustomChip(
                backgroundColor: Colors.white,
                textColor: Colors.black54,
                borderColor: Colors.black54,
                chipTitle: 'Read',
                iconData: Icons.archive_outlined,
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Cards list
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  CardsList<AssignmentItem>(
                    items: mockAssignments,
                    variant: CardVariant.assignment,
                    onAssignmentTap: (a) {
                      // Handle navigation if needed
                      debugPrint('Tapped: ${a.title}');
                    },
                  ),

                  // Spacer so bottom nav/FAB won’t cover the last card
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
