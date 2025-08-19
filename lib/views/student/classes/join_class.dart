import 'package:flutter/material.dart';
import 'package:flutter_lms/config/constants.dart';
import 'package:flutter_lms/config/routes.dart';
import 'package:flutter_lms/views/student/student_global_layout.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentJoinClass extends StatelessWidget {
  const StudentJoinClass({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StudentGlobalLayout(
        backgroundColor: AppConstants.mainColorTheme,
        useSafeArea: true,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Step into your learning journey.",
              style: GoogleFonts.poppins(color: Colors.grey.shade200),
            ),
            Text(
              "Join a Class",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 38,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "To begin, enter the class code provided by\nyour teacher. This will allow you to access\nclass materials, track your progress, and\ncollaborate with classmates.",
              style: GoogleFonts.poppins(
                color: Colors.grey.shade300,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 10),

            Card(
              elevation: 10,
              color: Colors.blue.shade900,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const TextField(
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Class Code",
                      hintStyle: TextStyle(color: Colors.black38),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    child: IconButton(
                      onPressed: () {
                        Get.toNamed(AppRoutes.studentJoinClassSuccess);
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                    ),
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
