import 'package:flutter/material.dart';
import 'package:flutter_lms/views/student/home/student_global_layout.dart';
import 'package:flutter_lms/widgets/app_bar.dart';
import 'package:flutter_lms/widgets/global_chip.dart';
import 'package:flutter_lms/widgets/global_student_badges_card.dart';
import 'package:flutter_lms/widgets/ui_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class GlobalBadgesPage extends StatelessWidget {
  const GlobalBadgesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final h = screen.height;
    final w = screen.width;

    return Scaffold(
      appBar: GlobalAppBar(
        title: 'Badges',
        onProfileTap: () {},
        onNotificationsTap: () {},
      ),
      body: SingleChildScrollView(
        child: StudentGlobalLayout(
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
                      colors: [Color(0xFF0034F8), Color(0xFF082BAB)],
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

              SizedBox(height: 10),

              Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.emoji_events),
                      SizedBox(width: 10),
                      Text("Earned Topics"),
                    ],
                  ),

                  SizedBox(height: 10),

                  BadgesCard(
                    subject: 'Quadratic Equations',
                    proficiency: 'Mastered',
                    time: '3:00PM',
                    duration: '20 mins',
                  ),
                  BadgesCard(
                    subject: 'Quadratic Equations',
                    proficiency: 'Mastered',
                    time: '3:00PM',
                    duration: '20 mins',
                  ),

                  SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0055FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 8,
                        shadowColor: const Color(0xFF0055FF).withOpacity(0.4),
                      ),
                      onPressed: () {},
                      child: Text(
                        'View all badges',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 15),

                  // Information only
                  InkCardShell(
                    onTap: () {},
                    leftAccent: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.emoji_events_rounded),
                            SizedBox(width: 5),
                            Text(
                              "What are badges",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          '''Badges are rewards you earn as you learn!\nThey show how well you understand each topic \nin a unit.''',
                        ),
                        SizedBox(height: 10),
                        Text("There are 3 types of badges:"),
                        SizedBox(height: 10),
                        Column(
                          children: [
                            BadgesType(
                              iconColor: Colors.amber,
                              icon: Icons.star,
                              badgeType: 'Mastered',
                            ),
                            BadgesType(
                              iconColor: Colors.green,
                              icon: Icons.circle,
                              badgeType: 'Proficient',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BadgesType extends StatelessWidget {
  final IconData icon;
  final String badgeType;
  final Color iconColor;

  const BadgesType({super.key, required this.icon, required this.badgeType, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Row(children: [Icon(icon, color: iconColor,), SizedBox(width: 5), Text(badgeType)]);
  }
}
