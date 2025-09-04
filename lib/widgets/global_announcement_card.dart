import 'package:flutter_lms/widgets/base_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GlobalAnnouncementCard extends BaseWidget {
  final String title;
  final String subtitle;
  final String delegations; // e.g., "Today, M, T, W • 8:00–9:30 AM"

  const GlobalAnnouncementCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.delegations,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final iconColor = Colors.grey.shade500;
    final iconSize = screenWidth * 0.045;
    final textStyle = TextStyle(
      color: Colors.grey.shade500,
      fontSize: screenWidth * 0.032,
    );

    return InkWell(
      // onTap: () => Get.toNamed(AppRoutes.),
      child: Card(
        color: Colors.white, // ✅ full white background
        margin: EdgeInsets.only(bottom: screenHeight * 0.015),
        elevation: 5,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // ✅ enforce white inside too
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
            border: Border(
              left: BorderSide(
                color: Colors.yellow,
                width: screenWidth * 0.005,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Top Image with fallback =====
              Container(
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  color: Colors.blue,
                ),
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(screenWidth * 0.025),
                    topRight: Radius.circular(screenWidth * 0.025),
                  ),
                  child: Icon(Icons.announcement),
                ),
              ),

              // ===== Text Section =====
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.025,
                  vertical: screenHeight * 0.015,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.045,
                      ),
                    ),

                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: screenWidth * 0.04,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // ===== Bottom (time & teacher) — wraps if needed =====
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(Icons.person, color: Colors.grey.shade500),
                        SizedBox(width: 5),
                        Text(
                          'To all Students',
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
