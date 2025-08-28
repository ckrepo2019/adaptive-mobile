// lib/views/student/classes/join_class.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_lms/config/constants.dart';
import 'package:flutter_lms/config/routes.dart';
import 'package:flutter_lms/controllers/api_response.dart';
import 'package:flutter_lms/controllers/student/student_class.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentJoinClass extends StatefulWidget {
  const StudentJoinClass({super.key});

  @override
  State<StudentJoinClass> createState() => _StudentJoinClassState();
}

class _StudentJoinClassState extends State<StudentJoinClass> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;

  Future<void> _joinClass() async {
    final code = _controller.text.trim();
    if (code.isEmpty) {
      _showNiceAlert(
        title: "Missing code",
        message: "Please enter a class code to continue.",
        intent: _AlertIntent.warning,
      );
      return;
    }

    setState(() => _loading = true);
    final ApiResponse<Map<String, dynamic>> res =
        await StudentClassController.joinClassByCode(classCode: code);
    setState(() => _loading = false);

    if (res.success) {
      Get.toNamed(
        AppRoutes.studentJoinClassSuccess,
        arguments: {
          ...?res.data, // { enrolled_id, subject_id, ... }
          'subject_code': _controller.text.trim(), // add this
        },
      );
    } else {
      _showNiceAlert(
        title: "Unable to join",
        message: res.message ?? "Please check the code and try again.",
        intent: _AlertIntent.error,
      );
    }
  }

  void _showNiceAlert({
    required String title,
    required String message,
    _AlertIntent intent = _AlertIntent.info,
    String buttonText = "OK",
    VoidCallback? onConfirm,
  }) {
    final List<Color> blueGradient = [
      const Color(0xFF4FACFE),
      const Color(0xFF00F2FE),
    ];

    showGeneralDialog(
      context: context,
      barrierLabel: 'alert',
      barrierDismissible: true,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.08),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 24,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: blueGradient),
                          boxShadow: [
                            BoxShadow(
                              color: blueGradient.first.withOpacity(0.4),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          height: 1.1,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.92),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                          height: 1.35,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: blueGradient),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              onConfirm?.call();
                            },
                            child: Text(
                              buttonText,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween(begin: 0.94, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // For responsive image sizing
    final w = MediaQuery.of(context).size.width;
    final imgWidth = (w * 0.105).clamp(300.0, 350.0);

    return Scaffold(
      backgroundColor: AppConstants.mainColorTheme,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Step into your learning journey.",
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                        Text(
                          "Join a Class",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 36,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "To begin, enter the class code provided by your teacher. "
                          "This will allow you to access class materials, track your progress, "
                          "and collaborate with classmates.",
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 14,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              TextField(
                                controller: _controller,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: "Class Code",
                                  hintStyle: const TextStyle(
                                    color: Color.fromARGB(200, 255, 255, 255),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 16,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.12),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 6,
                                child: _loading
                                    ? const Padding(
                                        padding: EdgeInsets.all(10),
                                        child: SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                    : IconButton(
                                        tooltip: "Join",
                                        onPressed: _joinClass,
                                        icon: const Icon(
                                          Icons.add,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Illustration (bottom-right), ignore taps so UI behind stays clickable
          Positioned(
            right: -100,
            bottom: -120,
            child: IgnorePointer(
              ignoring: true,
              child: Image.asset(
                'assets/images/student-class/join-class-model.png',
                width: imgWidth,
                fit: BoxFit.contain,
                alignment: Alignment.bottomRight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _AlertIntent { info, success, warning, error }
