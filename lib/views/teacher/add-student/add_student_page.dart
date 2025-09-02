import 'package:flutter/material.dart';
import 'package:flutter_lms/config/routes.dart';
import 'package:flutter_lms/views/teacher/teacher_global_layout.dart';
import 'package:flutter_lms/widgets/app_bar.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

class AddStudentPage extends StatelessWidget {
  const AddStudentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalAppBar(
        title: 'Adding students',
        subtitle: 'Essential Algebra for Beginners',
        showBack: true,
      ),
      body: TeacherGlobalLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 25),

            Center(
              child: Image(
                image: AssetImage('assets/images/utilities/students.png'),
                height: 200,
                width: 200,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Add a student",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 25),
            Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const TextField(
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: "Student ID",
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
                      icon: const Icon(Icons.add, color: Colors.black),
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
