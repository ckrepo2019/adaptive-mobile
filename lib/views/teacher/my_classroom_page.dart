import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_lms/views/teacher/learning-materials/learning_materials_page.dart';
import 'package:flutter_lms/views/teacher/teacher_global_layout.dart';
import 'package:flutter_lms/widgets/app_bar.dart';
import 'package:flutter_lms/widgets/global_chip.dart';
import 'package:google_fonts/google_fonts.dart';

class MyClassroomPage extends StatelessWidget {
  const MyClassroomPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const GlobalAppBar(
        title: 'My Classroom',
        showBack: true,
        showNotifications: false,
        showProfile: false,
      ),
      body: TeacherGlobalLayout(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Chips
                Row(
                  children: [
                    CustomChip(
                      backgroundColor: const Color(0xFFE6F4FF),
                      textColor: const Color(0xFF0B63CE),
                      borderColor: Colors.transparent,
                      chipTitle: 'Adviser : Ms. Celine',
                      iconData: Icons.verified_user_outlined,
                    ),
                    const SizedBox(width: 8),
                    CustomChip(
                      backgroundColor: Colors.grey.shade300,
                      textColor: Colors.black,
                      borderColor: Colors.transparent,
                      chipTitle: '30 Students',
                      iconData: Icons.people_alt_outlined,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Class card
                Container(
                  width: double.infinity,
                  height: 175,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      // Left side image
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        child: Image.asset(
                          'assets/images/default-images/default-female-teacher-class.png',
                          width: 180,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Right side text
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Class Emerald',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'NF03SS',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Mon, Wed, Fri - 9:00 AM',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Function tiles row (use Expanded to avoid overflow)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SizedBox(
                        width:
                            200, // fixed width so cards don't stretch too wide
                        child: FunctionCard(
                          title: 'Create\nAnnouncements',
                          onTap: () {
                            // TODO: navigate or open modal
                          }, buttonTitle: 'Create',
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 200,
                        child: FunctionCard(
                          title: 'Activate\nAssignments',
                          onTap: () {}, buttonTitle: 'Activate',
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 200,
                        child: FunctionCard(
                          title: 'Activate\nClass Materialas',
                          onTap: () {}, buttonTitle: 'Activate',
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: FunctionCard(
                          title: 'Add and Admit\nStudents',
                          onTap: () {}, buttonTitle: 'Add',
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 25,),

                _SectionTitle(iconData: Icons.access_time, sectionTitle: 'Active Assignments'),
                SizedBox(height: 10,),
                InkCardShell(
                  leftAccent: Colors.green,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Quiz - Order of Operations (PEMDAS)",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Text("Status: Active"),
                      const SizedBox(height: 20),
                      const Row(
                        children: [
                          SizedBox(width: 5),
                          Text("Ends in June 10, 2025 at 7:00 PM"),
                        ],
                      ),
                    ],
                  ),
                ),

                _SectionTitle(iconData: Icons.spatial_audio_outlined, sectionTitle: 'Top Announcements'),
                SizedBox(height: 10,),

                InkCardShell(
                  leftAccent: const Color(0xFFE11D48), // rose/red accent like the screenshot
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        "Teacher Introduction",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Posted meta
                      Text(
                        "Posted: Yesterday at 10:00 am",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black.withOpacity(0.55),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Body paragraphs
                      Text(
                        "Hi everyone! 👋\nI’m Mr. John Reyes, your Science teacher this school year. I’m excited to get to know each of you as we explore fun and interactive learning through AdaptiveHub.",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          height: 1.45,
                          color: Colors.black.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Expect engaging lessons, personalized activities, and lots of support along the way. Let’s work together to make this a great learning journey! 🚀",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          height: 1.45,
                          color: Colors.black.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Feel free to send me a message if you have any questions.\nSee you in class!",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          height: 1.45,
                          color: Colors.black.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Signature
                      Text(
                        "— Mr. Reyes",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10,),

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
                    onPressed: (){},
                    child: Text(
                      "View All Announcements",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 15,),
                _SectionTitle(iconData: Icons.note, sectionTitle: 'Subject List'),
                SizedBox(height: 10,),
                SubjectCard(),
                SizedBox(height: 5,),
                SubjectCard(),
                SizedBox(height: 5,),
                SubjectCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SubjectCard extends StatelessWidget {
  const SubjectCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkCardShell(leftAccent: Colors.red, child: Row(
      children: [
        Icon(Icons.calculate_rounded, size: 55, color: Colors.red,),
        SizedBox(width: 15,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Essential Algebra for Begginers", style: TextStyle(fontWeight: FontWeight.w500),),
            Text("23 Assignments", style: TextStyle(color: Colors.grey.shade500),),
          ],
        ),
      ],
    ));
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData iconData;
  final String sectionTitle;

  const _SectionTitle({
    required this.iconData,
    required this.sectionTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(iconData, size: 24),
        const SizedBox(width: 5),
        Text(
          sectionTitle,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
        ),
      ],
    );
  }
}


class FunctionCard extends StatelessWidget {
  const FunctionCard({super.key, required this.title, this.onTap, required this.buttonTitle});

  final String buttonTitle;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 180,
          width: 400,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0034F8), Color(0xFF082BAB)],
              stops: [0.1, 0.8],
            ),
          ),
          child: Stack(
            children: [
              // Content
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title (from param)
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const Spacer(),
                    // Chip-like CTA
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white),
                      ),
                      child: Text(
                        buttonTitle,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Decorative image
              Positioned(
                bottom: -10,
                right: -20,
                child: Image.asset(
                  'assets/images/utilities/streak_icon.png',
                  height: 120,
                  width: 120,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
