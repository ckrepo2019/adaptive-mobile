import 'package:flutter/material.dart';
import 'package:flutter_lms/config/constants.dart';
import 'package:flutter_lms/config/routes.dart';
import 'package:flutter_lms/widgets/global_chip.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentClassPage extends StatelessWidget {
  const StudentClassPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [ 

          Positioned(
              left: 100,
              bottom: -40,
              child: IgnorePointer(
                child: SizedBox(
                  height: 525,
                  child: Image.asset(
                    'assets/images/student-class/join-class-model.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Top Row =====
              Row(
                children: [
                  Text(
                    "Classes",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.08, // responsive title
                    ),
                  ),
                  const Spacer(),
                    
                  _buildIconButton(
                    context,
                    'assets/images/student-home/ci_bell-notification.png',
                    screenWidth,
                  ),
                  _buildIconButton(
                    context,
                    'assets/images/student-home/profile-icon.png',
                    screenWidth,
                  ),
                ],
              ),
                    
              SizedBox(height: screenHeight * 0.02),
                    
              // ===== Chips Row + Add Button =====
              Row(
                children: [
                  CustomChip(
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    borderColor: Colors.black54,
                    chipTitle: 'Current',
                    iconData: Icons.access_time,
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  CustomChip(
                    backgroundColor: Colors.white,
                    textColor: Colors.black54,
                    borderColor: Colors.black54,
                    chipTitle: 'Archived',
                    iconData: Icons.archive_outlined,
                  ),
                ],
              ),
                                        
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: screenWidth * 0.05),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "It seems that\nyou don't have\na class yet!",
                          style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1)
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        Container(
                          width: screenWidth * 0.45,
                          padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.012,
                            horizontal: screenWidth * 0.04,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(screenWidth * 0.025),
                            color: AppConstants.mainColorTheme,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, color: Colors.white, size: screenWidth * 0.045),
                              SizedBox(width: screenWidth * 0.02),
                              InkWell(
                                onTap: () {
                                  Get.toNamed(AppRoutes.studentJoinClass);
                                },
                                child: Text(
                                  "Join a class",
                                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500, letterSpacing: 1)
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
                    
            ],
                    ),
          ),
        ]
      ),
    );
  }

  // Reusable Icon Button
  Widget _buildIconButton(
      BuildContext context, String assetPath, double screenWidth) {
    return InkWell(
      onTap: () {},
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.015),
          child: Image.asset(
            assetPath,
            width: screenWidth * 0.06,
            height: screenWidth * 0.06,
          ),
        ),
      ),
    );
  }
}
