import 'package:flutter/material.dart';
import 'package:Adaptive/config/constants.dart';
import 'package:Adaptive/config/routes.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherAddStudentSuccess extends StatefulWidget {
  const TeacherAddStudentSuccess({super.key});

  @override
  State<TeacherAddStudentSuccess> createState() =>
      _TeacherAddClassSuccessState();
}

class _TeacherAddClassSuccessState extends State<TeacherAddStudentSuccess> {
  final ConfettiController _confettiController = ConfettiController(
    duration: const Duration(seconds: 2),
  );

  @override
  void initState() {
    super.initState();
    _confettiController.play();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final uid = prefs.getString('uid') ?? '';
      final userType = prefs.getInt('usertype_ID') ?? 4;

      Future.delayed(const Duration(seconds: 5), () {
        if (!mounted) return;
        Get.offAllNamed(
          AppRoutes.teacherShell,
          arguments: {
            'token': token,
            'uid': uid,
            'userType': userType,
            'initialIndex': 1,
          },
        );
      });
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Widget _confettiImage({bool flip = false, double size = 120}) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..scale(flip ? -1.0 : 1.0, 1.0, 1.0),
      child: Image.asset(
        'assets/images/student-class/confetti.png',
        width: size,
        fit: BoxFit.contain,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    String subjectCode = 'Your Class';
    if (args is Map) {
      subjectCode =
          (args['subject_code'] ?? args['subjectCode'] ?? args['subject'] ?? '')
              .toString()
              .trim();
      if (subjectCode.isEmpty) subjectCode = 'Your Class';
    }

    return Scaffold(
      backgroundColor: AppConstants.mainColorTheme,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 3.14 / 2,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
            ),
          ),
          Positioned(top: 200, left: -20, child: _confettiImage(size: 140)),
          Positioned(
            top: 100,
            right: 0,
            child: _confettiImage(flip: true, size: 100),
          ),
          Positioned(bottom: 130, left: 0, child: _confettiImage(size: 120)),
          Positioned(
            bottom: -20,
            right: -20,
            child: _confettiImage(flip: true, size: 160),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Added!",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Student\nSuccessfully",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 10,
                    color: Colors.green.shade500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      child: Center(
                        child: Text(
                          subjectCode,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
