// lib/views/student/profile_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_lms/widgets/app_bar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  double _clamp(double v, double min, double max) =>
      v < min ? min : (v > max ? max : v);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;

    // --- get student from route args ---
    final args = ModalRoute.of(context)?.settings.arguments;
    final Map<String, dynamic> student = (args is Map && args['student'] is Map)
        ? Map<String, dynamic>.from(args['student'] as Map)
        : const {};
    final String first = (student['firstname']?.toString().trim() ?? '');
    final String welcomeName = first.isNotEmpty ? first : 'Student';

    final double padX = _clamp(w * 0.06, 16, 24);
    final double helloSize = _clamp(w * 0.06, 16, 32);
    final double subSize = _clamp(w * 0.040, 12, 24);

    // Make the header a bit taller so the big illo can bleed nicely
    final double headerHeight = _clamp(h * 0.38, 280, 360);

    // Start the blue sheet a little higher so the art visibly overlaps it
    final double sheetTop = _clamp(h * 0.35, 300, 420);
    final double sheetRadius = 26;

    // Illustration sizing/positioning: large + pushed right and down
    final double illoW = _clamp(w * 1, 380, 600); // larger
    final double illoH = illoW * 0.90;
    final double illoRightBleed = _clamp(w * 0.28, 40, 100);
    final double illoDrop = _clamp(h * 0.10, 40, 80); // less drop (higher up)

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const GlobalAppBar(title: 'Profile', showBack: true),
      body: Stack(
        children: [
          // CONTENT UNDER THE SHEET (including the big illustration)
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: _clamp(h * 0.18, 140, 220)),
              child: Column(
                children: [
                  SizedBox(
                    height: headerHeight,
                    width: double.infinity,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Text block
                        Padding(
                          padding: EdgeInsets.only(
                            left: padX * 1.3,
                            right: padX * 1.3,
                            top: padX * 2.2,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome $welcomeName.',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: helloSize,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Visual Learner',
                                style: GoogleFonts.poppins(
                                  fontSize: subSize,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // BIG illustration bleeding to the right and down into the sheet
                        Positioned(
                          right: -illoRightBleed,
                          bottom: -illoDrop,
                          child: SizedBox(
                            width: illoW,
                            height: illoH,
                            child: Image.asset(
                              'assets/images/student-profile/default-female-profile.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // BLUE SHEET ON TOP (so it overlaps the illustration nicely)
          Positioned(
            left: 0,
            right: 0,
            top: sheetTop,
            bottom: 0,
            child: _ProfileSheet(
              radius: sheetRadius,
              padX: padX,
              onLogout: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logout tapped'),
                    duration: Duration(milliseconds: 900),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSheet extends StatelessWidget {
  const _ProfileSheet({
    required this.radius,
    required this.padX,
    required this.onLogout,
  });

  final double radius;
  final double padX;
  final VoidCallback onLogout;

  static double _clamp(double v, double min, double max) =>
      v < min ? min : (v > max ? max : v);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Material(
      elevation: 10,
      shadowColor: const Color(0x33000000),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(radius),
        topRight: Radius.circular(radius),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1F5BFF),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(radius),
            topRight: Radius.circular(radius),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  child: Icon(Icons.edit, color: Colors.white),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padX * 1.8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _Field(label: 'Name', value: 'Emma Watsons'),
                  _Field(label: 'Learner Type', value: 'Visual Learner'),
                  _Field(label: 'Grade Level', value: 'Grade 7 – Helium'),
                  _Field(label: 'Birthdate', value: 'January 31, 2004'),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.fromLTRB(padX, 8, padX, 18),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  onPressed: onLogout,
                  child: Text(
                    'Logout',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF1F5BFF),
                      fontWeight: FontWeight.w600,
                      fontSize: _clamp(w * 0.045, 14, 18),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    double clamp(double v, double min, double max) =>
        v < min ? min : (v > max ? max : v);
    final double labelSize = clamp(w * 0.032, 11, 13);
    final double valueSize = clamp(w * 0.045, 15, 18);

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.85),
              fontSize: labelSize,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: valueSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
