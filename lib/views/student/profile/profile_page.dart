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
    final double helloSize = _clamp(w * 0.055, 16, 20);
    final double subSize = _clamp(w * 0.040, 12, 16);
    final double illoSize = _clamp(w * 0.48, 160, 230);

    // where the blue card starts
    final double sheetTop = _clamp(h * 0.40, 340, 460);
    final double sheetRadius = 26;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const GlobalAppBar(title: 'Profile', showBack: true),
      body: Stack(
        children: [
          // ---------- Header (ROW: text | illustration) ----------
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: _clamp(h * 0.18, 140, 220)),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(padX, 12, padX, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Texts on the left
                        Expanded(
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
                                textAlign: TextAlign.start,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Visual Learner',
                                style: GoogleFonts.poppins(
                                  fontSize: subSize,
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ],
                          ),
                        ),

                        // Illustration on the right (asset image)
                        SizedBox(
                          width: illoSize,
                          height: illoSize * 0.78,
                          child: Image.asset(
                            'assets/images/student-profile/default-female-profile.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: _clamp(h * 0.12, 48, 80)),
                ],
              ),
            ),
          ),

          // ---------- Floating Blue Sheet ----------
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
    final double labelSize = _clamp(w * 0.032, 11, 13);
    final double valueSize = _clamp(w * 0.045, 15, 18);

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
            // edit icon row
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit, color: Colors.white),
                ),
                const SizedBox(width: 6),
              ],
            ),

            // fields
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padX),
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

            // logout button
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
                      borderRadius: BorderRadius.circular(28),
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
    double _clamp(double v, double min, double max) =>
        v < min ? min : (v > max ? max : v);
    final double labelSize = _clamp(w * 0.032, 11, 13);
    final double valueSize = _clamp(w * 0.045, 15, 18);

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
