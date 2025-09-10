import 'package:flutter/material.dart';
import 'package:Adaptive/widgets/app_bar.dart';
import 'package:Adaptive/widgets/global_chip.dart';
import 'package:Adaptive/widgets/global_leaderboard_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final h = screen.height;
    final w = screen.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const GlobalAppBar(title: 'Leaderboard'),
      body: Column(
        children: [
          /// --- Profile Card ---
          Padding(
            padding: EdgeInsets.all(w * 0.03), // responsive padding
            child: Card(
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
                            "Rank #5",
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
                            textColor: Colors.orange.shade900,
                            borderColor: Colors.orange,
                            chipTitle: '2420',
                            iconData: Icons.person,
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
          ),

          SizedBox(height: h * 0.02),

          /// --- Podium + Rankings ---
          Expanded(
            child: Column(
              children: [
                /// Podium
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    LeaderboardWidget(
                      name: 'Sofia',
                      radius: w * 0.12,
                      height: h * 0.22,
                      width: w * 0.25,
                    ),
                    SizedBox(width: w * 0.03),
                    LeaderboardWidget(
                      name: 'Alex',
                      radius: w * 0.16,
                      height: h * 0.3,
                      width: w * 0.35,
                    ),
                    SizedBox(width: w * 0.03),
                    LeaderboardWidget(
                      name: 'Marcus',
                      radius: w * 0.12,
                      height: h * 0.22,
                      width: w * 0.25,
                    ),
                  ],
                ),

                /// Full Rankings (Scrollable)
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(w * 0.04),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 8,
                          color: Colors.black12,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.emoji_events),
                            SizedBox(width: w * 0.02),
                            Text(
                              "Full Rankings",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: w * 0.045,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: h * 0.015),

                        /// Scrollable list
                        Expanded(
                          child: ListView(
                            children: const [
                              GlobalLeaderboardWidget(
                                  studentName: 'Alex Chen',
                                  badgeTitle: 'Quiz Master'),
                              GlobalLeaderboardWidget(
                                  studentName: 'Maria Lopez',
                                  badgeTitle: 'Top Coder'),
                              GlobalLeaderboardWidget(
                                  studentName: 'John Smith',
                                  badgeTitle: 'Fast Solver'),
                              GlobalLeaderboardWidget(
                                  studentName: 'Sophia Reyes',
                                  badgeTitle: 'Critical Thinker'),
                              GlobalLeaderboardWidget(
                                  studentName: 'David Kim',
                                  badgeTitle: 'Quiz Master'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// --- Podium Widget ---
class LeaderboardWidget extends StatelessWidget {
  final double radius;
  final double height;
  final double width;
  final String name;

  const LeaderboardWidget({
    super.key,
    required this.radius,
    required this.height,
    required this.width,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        /// Podium base
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.yellow.shade700,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(128),
              topRight: Radius.circular(128),
            ),
          ),
        ),

        /// Avatar + Name
        Positioned(
          top: 2,
          child: Column(
            children: [
              CircleAvatar(
                radius: radius,
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: Image.network(
                    'https://images.pexels.com/photos/1391498/pexels-photo-1391498.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
                    fit: BoxFit.cover,
                    width: radius * 2,
                    height: radius * 2,
                  ),
                ),
              ),
              SizedBox(height: height * 0.02),
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: radius * 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
