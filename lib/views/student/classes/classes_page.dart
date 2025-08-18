import 'package:flutter/material.dart';
import 'package:flutter_lms/widgets/app_bar.dart';
import 'package:flutter_lms/views/student/home/student_global_layout.dart';
import 'package:flutter_lms/widgets/global_chip.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_lms/widgets/global_subject_widget.dart';
import 'package:flutter_lms/config/routes.dart';

class StudentClassPage extends StatelessWidget {
  const StudentClassPage({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: GlobalAppBar(
        title: 'Classes',
        onNotificationsTap: () {},
        onProfileTap: () {},
      ),
      body: StudentGlobalLayout(
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
                SizedBox(width: w * 0.02),
                const CustomChip(
                  backgroundColor: Colors.white,
                  textColor: Colors.black54,
                  borderColor: Colors.black54,
                  chipTitle: 'Archived',
                  iconData: Icons.archive_outlined,
                ),
                const Spacer(),
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.studentJoinClass);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: w * 0.03,
                      vertical: h * 0.008,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: const Color(0xFF234EF4),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.add, size: w * 0.04, color: Colors.white),
                        SizedBox(width: w * 0.015),
                        Text(
                          'Add Class',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: w * 0.035,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: h * 0.03),

            // ===== Subject List =====
            Expanded(
              child: ListView(
                children: const [
                  GlobalSubjectWidget(
                    subject: 'Mathematics',
                    classCode: 'Math Class 101',
                    time: '11:00 AM', // pass raw time; widget adds "Today, "
                    teacherName: 'Alix, John Richard',
                  ),
                  GlobalSubjectWidget(
                    subject: 'Mathematics',
                    classCode: 'Math Class 101',
                    time: '11:00 AM', // pass raw time; widget adds "Today, "
                    teacherName: 'Alix, John Richard',
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
