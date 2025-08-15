import 'package:flutter/material.dart';
import 'package:flutter_lms/views/student/home/student_global_layout.dart';
import 'package:flutter_lms/widgets/global_chip.dart';
import 'package:flutter_lms/widgets/global_subject_widget.dart';

class StudentClassPage extends StatelessWidget {
  const StudentClassPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScale = MediaQuery.of(context).textScaleFactor;

    return StudentGlobalLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== Top Row =====
          Row(
            children: [
              Text(
                "Classes",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.08, // responsive title
                ),
              ),
              const Spacer(),

              _buildIconButton(
                context,
                'assets/images/student-home/ci_bell-notification.png',
                screenWidth,
              ),
              _buildIconButton(
                context,
                'assets/images/student-home/profile-icon.png',
                screenWidth,
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.02),

          // ===== Chips Row + Add Button =====
          Row(
            children: [
              CustomChip(
                backgroundColor: Colors.black,
                textColor: Colors.white,
                borderColor: Colors.black54,
                chipTitle: 'Current',
                iconData: Icons.access_time,
              ),
              SizedBox(width: screenWidth * 0.02),
              CustomChip(
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
                    Icon(Icons.add,
                        size: screenWidth * 0.04, color: Colors.white),
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
              children: [
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
    );
  }

  // Reusable Icon Button
  Widget _buildIconButton(
      BuildContext context, String assetPath, double screenWidth) {
    return InkWell(
      onTap: () {},
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.015),
          child: Image.asset(
            assetPath,
            width: screenWidth * 0.06,
            height: screenWidth * 0.06,
          ),
        ),
      ),
    );
  }
}
