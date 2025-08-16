// lib/views/student/home/student_class_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_lms/widgets/app_bar.dart'; // <—
import 'package:flutter_lms/views/student/home/student_global_layout.dart';
import 'package:flutter_lms/widgets/global_chip.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentClassPage extends StatelessWidget {
  const StudentClassPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: GlobalAppBar(
        // <— set here
        title: 'Classes',
        onNotificationsTap: () {}, // wire as needed
        onProfileTap: () {},
      ),
      body: StudentGlobalLayout(
        // padding/safe-area only
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Chips Row + Add Button =====
            Row(
              children: [
                const CustomChip(
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  borderColor: Colors.black54,
                  chipTitle: 'Current',
                  iconData: Icons.access_time,
                ),
                SizedBox(width: screenWidth * 0.02),
                const CustomChip(
                  backgroundColor: Colors.white,
                  textColor: Colors.black54,
                  borderColor: Colors.black54,
                  chipTitle: 'Archived',
                  iconData: Icons.archive_outlined,
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
                    vertical: screenHeight * 0.008,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color.fromARGB(255, 35, 78, 244),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add,
                        size: screenWidth * 0.04,
                        color: Colors.white,
                      ),
                      SizedBox(width: screenWidth * 0.015),
                      Text(
                        "Add Class",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.035,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: screenHeight * 0.03),

            // ===== Subject List =====
            Expanded(
              child: ListView(
                children: const [
                  GlobalSubjectWidget(
                    subject: 'Mathematics',
                    classCode: 'Math Class 101',
                    time: 'Today, 11:00 AM',
                    teacherName: 'Alix, John Richard',
                  ),
                  GlobalSubjectWidget(
                    subject: 'Science',
                    classCode: 'Science Class 202',
                    time: 'Tomorrow, 2:00 PM',
                    teacherName: 'Jane Doe',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
