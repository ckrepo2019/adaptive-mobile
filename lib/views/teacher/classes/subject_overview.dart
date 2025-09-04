import 'package:flutter/material.dart';
import 'package:flutter_lms/views/student/home/quick_actions.dart';
import 'package:flutter_lms/views/teacher/teacher_global_layout.dart';
import 'package:flutter_lms/widgets/app_bar.dart';
import 'package:flutter_lms/widgets/class_progress_card.dart';
import 'package:flutter_lms/widgets/global_chip.dart';
import 'package:flutter_lms/widgets/ui_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class SubjectOverview extends StatelessWidget {
  const SubjectOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalAppBar(
        title: 'Subject Overview',
        subtitle: 'Essential Algebra for Beginners',
        showBack: true,
        showProfile: false,
        showNotifications: false,
      ),

      body: TeacherGlobalLayout(
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
                SizedBox(width: 5),
                CustomChip(
                  backgroundColor: Colors.white,
                  textColor: Colors.grey.shade500,
                  borderColor: Colors.grey.shade500,
                  chipTitle: 'About',
                  iconData: Icons.mail,
                ),
              ],
            ),

            SizedBox(height: 15),

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
                    // Progress circle on the left
                    ClassProgressCard(
                      value: 0.10,
                      size: 120,
                      strokeWidth: 5,
                      // label: 'test',
                      showShadow: false,
                    ),

                    const SizedBox(width: 20),

                    // Texts on the right
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Topic',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'The Language\nof Algebra',
                            style: const TextStyle(
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

            SizedBox(height: 15),

            SectionTitle(iconData: Icons.access_time, sectionTitle: 'Active Materials',),
            SizedBox(height: 10,),
            InkCardShell(leftAccent: Colors.green, child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Quiz - Order of Operations (PEMDAS)", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),),
                Text("Status: Active"),
                SizedBox(height: 20,),

                Row(
                  children: [
                    Icon(Icons.alarm),
                    SizedBox(width: 5,),
                    Text("Ends in June 10, 2025 at 7:00 PM"),
                  ],
                ),

              ],
            )),

            SizedBox(height: 20,),

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

                // Grid is non-scrollable inside the parent scroll view
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
                      onTap: () {
                        
                      },
                    ),
                    QuickActionTile(
                      iconAsset: 'assets/images/student-home/leaderboards-quickactions.png',
                      label: 'Leaderboards',
                      onTap: () {
                      },
                    ),
                    QuickActionTile(
                      iconAsset: 'assets/images/student-home/leaderboards-quickactions.png',
                      label: 'Attendance',
                      onTap: () {},
                    ),
                    QuickActionTile(
                      iconAsset: 'assets/images/student-home/leaderboards-quickactions.png',
                      label: 'Students',
                      onTap: () {},
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  
  final IconData iconData;
  final String sectionTitle;

  const SectionTitle({super.key, required this.iconData, required this.sectionTitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(iconData, size: 24),
        SizedBox(width: 5),
        Text(
          sectionTitle,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
        ),
      ],
    );
  }
}
