import 'package:flutter/material.dart';
import 'package:flutter_lms/views/utilities/layouts/global_layout.dart';
import 'package:flutter_lms/widgets/app_bar.dart';
import 'package:flutter_lms/widgets/global_chip.dart';
import 'package:flutter_lms/widgets/global_student_badges_card.dart';
import 'package:google_fonts/google_fonts.dart';

class BadgesPage extends StatelessWidget {
  const BadgesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final h = screen.height;
    final w = screen.width;
    
    return Scaffold(
      appBar: GlobalAppBar(title: 'My Badges', onProfileTap: (){}, onNotificationsTap: (){},),
      body: StudentGlobalLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
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
                  Padding(
                    padding: EdgeInsets.all(w * 0.04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Emma Watsons",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: w * 0.035,
                          ),
                        ),
                        Text(
                          "Math 101",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: w * 0.1,
                            color: Colors.white,
                            height: 1.0,
                          ),
                        ),
                        SizedBox(height: h * 0.05),
                        CustomChip(
                          backgroundColor: Colors.yellow.shade200,
                          textColor: Colors.orange.shade800,
                          borderColor: Colors.orange,
                          chipTitle: '4 Badges Earned',
                          iconData: Icons.emoji_events,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: -h * 0.04,
                    right: -w * 0.05,
                    child: Image.asset(
                      "assets/images/utilities/streak_icon.png",
                      height: h * 0.15,
                      width: w * 0.25,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 10,),

          Row(
            children: [
              Icon(Icons.emoji_events),
              SizedBox(width: 10,),
              Text("Math 101: Earned Topics"),
            ],
          ),

          SizedBox(height: 10,),

          BadgesCard(subject: 'Quadratic Equations', proficiency: 'Mastered', time: '3:00PM', duration: '20 mins'),
          BadgesCard(subject: 'Quadratic Equations', proficiency: 'Mastered', time: '3:00PM', duration: '20 mins'),
          BadgesCard(subject: 'Quadratic Equations', proficiency: 'Mastered', time: '3:00PM', duration: '20 mins'),
          BadgesCard(subject: 'Quadratic Equations', proficiency: 'Mastered', time: '3:00PM', duration: '20 mins'),

        ],
      )),
    );
  }
}

