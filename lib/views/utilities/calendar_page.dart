import 'package:flutter/material.dart';
import 'package:flutter_lms/config/constants.dart';
import 'package:flutter_lms/views/student/home/student_global_layout.dart';
import 'package:flutter_lms/widgets/app_bar.dart';
import 'package:flutter_lms/widgets/global_basic_information_widget.dart';
import 'package:flutter_lms/widgets/global_chip.dart';
import 'package:google_fonts/google_fonts.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: GlobalAppBar(showBack: false, title: 'Calendar'),
      body: StudentGlobalLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20,),

          Card(
          elevation: 20,
          child: Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 0, 52, 248),
                  Color.fromARGB(255, 8, 43, 171),
                ],
                stops: [0.1, 0.8],
              ),
            ),
            child: Stack(
              children: [
                // Text content on top-left
                Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your Streak",
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade200,
                          fontSize: 12,
                          height: 2.1
                        ),
                      ),
                      Text(
                        "22 Days",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 40,
                          color: Colors.white,
                          height: 0.9,
                        ),
                      ),
                    ],
                  ),
                ),

                // Fire icon on bottom-right
                Positioned(
                  bottom: -15,
                  right: -10,
                  child: Image.asset(
                    "assets/images/utilities/streak_icon.png",
                    height: 100,
                    width: 100,
                  ),
                ),
              ],
            ),
          ),
        )


        ],
      ),
      ),
    );
  }
}