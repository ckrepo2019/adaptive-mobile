import 'package:flutter/material.dart';
import 'package:flutter_lms/views/utilities/layouts/global_layout.dart';
import 'package:flutter_lms/widgets/app_bar.dart';
import 'package:flutter_lms/widgets/ui_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class SubjectClasses extends StatelessWidget {
  const SubjectClasses({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      appBar: GlobalAppBar(title: 'Subject Classes', showBack: true,),
      body: StudentGlobalLayout(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
                elevation: 10,
                child: Container(
                  width: double.infinity,
                  height: screenHeight * 0.18, // ✅ responsive height
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
                        right: -0,
                        top: 0,
                        bottom: -15, // stretches vertically
                        child: Image.asset(
                          'assets/images/utilities/student_throw_cap.png',
                          width: screenWidth * 0.45,
                          height: screenHeight * 0.45,
                          fit: BoxFit.contain,
                        ),
                      ),

                      // ✅ Text stays on left
                      Padding(
                        padding: EdgeInsets.all(screenWidth * 0.06),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Celine\'s Classes', style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 12
                            ),),
                            Text(
                              "Math 101",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.09,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 25,),

              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(Icons.person_2),
                  SizedBox(width: 5,),
                  Text("Sections", style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 16),),
                ],
              ),

              SizedBox(height: 10,),

              Sections_Card(),
              Sections_Card(),
              Sections_Card(),


        ],
      )),
    );
  }
}

class Sections_Card extends StatelessWidget {
  const Sections_Card({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkCardShell(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Grade 7 - Emerald", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),),
        Text("Class Code: 0x0808"),
        SizedBox(height: 15,),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Icon(Icons.person, color: Colors.grey.shade500,),
            SizedBox(width: 5,),
            Text("20 Students", style: TextStyle(color: Colors.grey.shade500),)
          ],
        )
      ],
    ), leftAccent: Colors.black);
  }
}