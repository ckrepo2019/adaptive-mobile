// lib/views/student/quizzes/remedial_quiz_result.dart
import 'package:flutter/material.dart';
import 'package:flutter_lms/config/routes.dart';
import 'package:google_fonts/google_fonts.dart';

class RemedialQuizResultPage extends StatelessWidget {
  const RemedialQuizResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF2F6BFF), Color(0xFF1537B9)],
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "You Completed\nthe Remedial Quiz",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.achievements,
                          (route) => false,
                          arguments: {},
                        );
                      },
                      child: Text(
                        "View Results",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: -80,
            right: -50,
            child: Image.asset(
              "assets/images/assignments/remedial-result-model.png",
              width: 300,
            ),
          ),
        ],
      ),
    );
  }
}
