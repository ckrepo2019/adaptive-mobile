import 'package:flutter/material.dart';
import 'package:flutter_lms/config/constants.dart';
import 'package:flutter_lms/config/routes.dart';
import 'package:flutter_lms/views/teacher/teacher_global_layout.dart';
import 'package:flutter_lms/widgets/app_bar.dart';
import 'package:flutter_lms/widgets/global_chat_widget.dart';
import 'package:flutter_lms/widgets/global_chip.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class TeacherStudentPage extends StatelessWidget {
  const TeacherStudentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: GlobalAppBar(
        title: 'Students',
        subtitle: 'Essential Algebra',
        showBack: true,
      ),
      body: TeacherGlobalLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomChip(
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  borderColor: Colors.transparent,
                  chipTitle: 'Date added',
                  iconData: Icons.access_time,
                ),
                const SizedBox(width: 5),
                CustomChip(
                  backgroundColor: Colors.transparent,
                  textColor: Colors.black,
                  borderColor: Colors.black54,
                  chipTitle: 'A-Z',
                  iconData: Icons.filter,
                ),
              ],
            ),

            const SizedBox(height: 15),

            const GlobalChatWidget(
              studentName: 'Emma Watsons',
              section: 'Grade 7 - Emerald',
            ),
            const GlobalChatWidget(
              studentName: 'Emma Watsons',
              section: 'Grade 7 - Emerald',
            ),
            const GlobalChatWidget(
              studentName: 'Emma Watsons',
              section: 'Grade 7 - Emerald',
            ),
            const GlobalChatWidget(
              studentName: 'Emma Watsons',
              section: 'Grade 7 - Emerald',
            ),
          ],
        ),
      ),

      // ✅ Add button at the very bottom
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 10,
          child: SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.mainColorTheme,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                // Get.toNamed(AppRoutes.addStudentPage);
              },
              child: const Text(
                'Add Student',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
