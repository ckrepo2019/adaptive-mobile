import 'package:flutter/material.dart';
import 'package:flutter_lms/config/routes.dart';
import 'package:flutter_lms/views/teacher/teacher_global_layout.dart';
import 'package:flutter_lms/widgets/app_bar.dart';
import 'package:flutter_lms/widgets/class_progress_card.dart';
import 'package:flutter_lms/widgets/global_chip.dart';
import 'package:flutter_lms/views/student/home/quick_actions.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_lms/widgets/ui_widgets.dart';

class TeacherSubjectOverview extends StatelessWidget {
  const TeacherSubjectOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments is Map ? (Get.arguments as Map) : const {};
    final subjectId = args['subjectId'] as int?;
    final subjectName = (args['subject_name'] ?? 'Subject Overview').toString();
    final subjectCode = (args['subjectCode'] ?? '—').toString();
    final sectionName = (args['sectionName'] ?? '—').toString();
    final levelName = (args['levelName'] ?? '—').toString();
    final teacherFullname = (args['teacherFullname'] ?? 'TBA').toString();
    final imageUrl = args['image']?.toString();

    print('📄 SubjectOverview args => '
        'id=$subjectId, name=$subjectName, code=$subjectCode, section=$sectionName, '
        'level=$levelName, teacher=$teacherFullname, image=$imageUrl');

    return Scaffold(
      appBar: GlobalAppBar(
        title: 'Subject Overview',
        subtitle: subjectName, // ✅ subtitle uses the tapped subject name
        showBack: true,
        showProfile: false,
        showNotifications: false,
      ),
      body: TeacherGlobalLayout(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Row(
                children: [
                  CustomChip(
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    borderColor: Colors.transparent,
                    chipTitle: 'Dashboard',
                    iconData: Icons.access_time,
                  ),
                  const SizedBox(width: 5),
                  CustomChip(
                    backgroundColor: Colors.white,
                    textColor: Colors.grey.shade500,
                    borderColor: Colors.grey.shade500,
                    chipTitle: 'About',
                    iconData: Icons.mail,
                  ),
                ],
              ),
              const SizedBox(height: 15),

              Card(
                elevation: 10,
                child: Container(
                  height: 190,
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ClassProgressCard(
                        value: 0.10,
                        size: 120,
                        strokeWidth: 5,
                        showShadow: false,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Current Topic',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'The Language\nof Algebra',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Unit 1 - Lesson 2',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              const _SectionTitle(
                iconData: Icons.access_time,
                sectionTitle: 'Active Materials',
              ),
              const SizedBox(height: 10),

              InkCardShell(
                leftAccent: Colors.green,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Quiz - Order of Operations (PEMDAS)",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Text("Status: Active"),
                    const SizedBox(height: 20),
                    const Row(
                      children: [
                        Icon(Icons.alarm),
                        SizedBox(width: 5),
                        Text("Ends in June 10, 2025 at 7:00 PM"),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Quick Actions header
              Row(
                children: [
                  const Icon(Icons.open_in_new),
                  const SizedBox(width: 10),
                  Text(
                    "Quick Actions",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  QuickActionTile(
                    iconAsset: 'assets/images/student-home/classes-quickactions.png',
                    label: 'Learning Materials',
                    onTap: () {},
                  ),
                  QuickActionTile(
                    iconAsset: 'assets/images/student-home/leaderboards-quickactions.png',
                    label: 'Leaderboards',
                    onTap: () {},
                  ),
                  QuickActionTile(
                    iconAsset: 'assets/images/student-home/leaderboards-quickactions.png',
                    label: 'Attendance',
                    onTap: () {},
                  ),
                  QuickActionTile(
                    iconAsset: 'assets/images/student-home/leaderboards-quickactions.png',
                    label: 'Students',
                    onTap: () {
                      Get.toNamed(
                        AppRoutes.teacherStudents,
                        arguments: {
                          'subjectId': subjectId,
                          'subjectName': subjectName,
                          'sectionName': sectionName,
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData iconData;
  final String sectionTitle;

  const _SectionTitle({
    required this.iconData,
    required this.sectionTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(iconData, size: 24),
        const SizedBox(width: 5),
        Text(
          sectionTitle,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
        ),
      ],
    );
  }
}
