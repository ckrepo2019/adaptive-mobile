import 'package:flutter/material.dart';
import 'package:flutter_lms/config/routes.dart';
import 'package:flutter_lms/views/student/home/quick_actions.dart';
import 'package:flutter_lms/views/student/home/student_global_layout.dart';
import 'package:flutter_lms/views/teacher/widgets/class_timeline.dart';
import 'package:flutter_lms/widgets/app_bar.dart';
import 'package:flutter_lms/widgets/global_chip.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

class TeacherHomePage extends StatelessWidget {
  const TeacherHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GlobalAppBar(title: 'Home'),
      body: GlobalLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WelcomeWidget(),
            const SizedBox(height: 25),

            // Quick Actions header
            Row(
              children: [
                const Icon(Icons.open_in_new),
                const SizedBox(width: 10),
                Text(
                  "Quick Actions",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2, // 2 columns
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5, // > 1 makes it rectangular (width > height)
            children: [
              QuickActionTile(
                iconAsset: 'assets/images/student-home/classes-quickactions.png',
                label: 'Classes',
                onTap: () {
                  /* navigate */
                },
              ),
              QuickActionTile(
                iconAsset: 'assets/images/student-home/leaderboards-quickactions.png',
                label: 'Announcements',
                onTap: () {
                  /* navigate */
                  Get.toNamed(AppRoutes.announcementPage);
                },
              ),
              QuickActionTile(
                iconAsset: 'assets/images/student-home/leaderboards-quickactions.png',
                label: 'Leaderboards',
                onTap: () {
                  /* navigate */
                },
              ),
              QuickActionTile(
                iconAsset: 'assets/images/student-home/leaderboards-quickactions.png',
                label: 'Profile',
                onTap: () {
                  /* navigate */
                },
              ),
            ],
          ),

          SizedBox(height: 25,),

          Row(
            children: [
              Icon(Icons.book,),
              SizedBox(width: 5,),
              Text("Today's Classes"),
              Spacer(),
              CustomChip(backgroundColor: Colors.blue.shade100, textColor: Colors.blue.shade500, borderColor: Colors.transparent, chipTitle: '4 Classes'),
            ],
          ),

          SizedBox(height: 25,),

          ClassTimeline(),
          ClassTimeline(),


            
          ],
        ),
      ),
    );
  }
}

class WelcomeWidget extends StatelessWidget {
  const WelcomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + Name
          Row(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFFF1F3F6),
                backgroundImage: AssetImage(
                  'assets/images/student-home/default-avatar-female.png',
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Welcome Celine.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  Text('Teacher'),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Chips row
          Row(
            children: [
              CustomChip(
                backgroundColor: Colors.grey,
                textColor: Colors.white,
                borderColor: Colors.transparent,
                chipTitle: '30 Students',
                iconData: Icons.person,
              ),
              const SizedBox(width: 5),
              CustomChip(
                backgroundColor: Colors.lightBlueAccent.shade100,
                textColor: Colors.blue.shade800,
                borderColor: Colors.transparent,
                chipTitle: 'Grade 1 : Joy Adviser',
                iconData: Icons.class_,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
