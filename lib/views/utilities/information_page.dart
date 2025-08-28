import 'package:flutter/material.dart';
import 'package:flutter_lms/views/student/home/student_global_layout.dart';
import 'package:flutter_lms/widgets/app_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class InformationPage extends StatelessWidget {
  const InformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: const GlobalAppBar(title: "Info", showBack: true),
      body: GlobalLayout(
        child: SingleChildScrollView( // ✅ allows scrolling on small devices
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Top Banner =====
              Card(
                elevation: 10,
                child: Container(
                  width: double.infinity,
                  height: screenHeight * 0.22, // ✅ responsive height
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF0034F8),
                        Color(0xFF082BAB),
                      ],
                      stops: [0.1, 0.8],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // ✅ Background image on the right
                      Positioned(
                        right: -60,
                        top: 0,
                        bottom: 0, // stretches vertically
                        child: Image.asset(
                          'assets/images/utilities/streak_icon.png',
                          width: screenWidth * 0.45,
                          height: screenHeight * 0.45,
                          fit: BoxFit.contain,
                        ),
                      ),

                      // ✅ Text stays on left
                      Padding(
                        padding: EdgeInsets.all(screenWidth * 0.06),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Enrollment Is\nNow Open!",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.07,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              // ===== Section Title =====
              Text(
                "About this Announcement",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.045, // ✅ responsive font size
                ),
              ),
              SizedBox(height: screenHeight * 0.012),

              // ===== Body Text =====
              Text(
                """We are excited to announce that enrollment is now officially open for the upcoming school year! Whether you’re a new student or returning learner, now is the perfect time to secure your spot at Gabriel Taborin College of Davao Foundation, Inc.

Enrollment is open for both our college degree programs and TESDA-accredited vocational courses. Make sure to complete your requirements early to avoid the rush.""",
                style: TextStyle(fontSize: screenWidth * 0.038, height: 1.4),
              ),

              SizedBox(height: screenHeight * 0.015),

              Text(
                """Enrollment Period:  Monday to Friday, 8:00 AM – 5:00 PM
📍 Location: Lasang, Davao City
📞 Contact Us: (082) 236-0452 or gabrieltaborincollegeofdavao@gmail.com

Get ready to grow with us — academically, personally, and spiritually!""",
                style: TextStyle(fontSize: screenWidth * 0.038, height: 1.4),
              ),
              SizedBox(height: screenHeight * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}
