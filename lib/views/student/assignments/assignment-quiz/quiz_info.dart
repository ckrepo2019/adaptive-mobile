import 'package:flutter/material.dart';
import 'package:flutter_lms/config/routes.dart';
import 'package:flutter_lms/widgets/app_bar.dart'; // your GlobalAppBar path
import 'package:google_fonts/google_fonts.dart';

class QuizInfoItem {
  final String title;
  final String subject;
  final String date;
  final String duration;
  final String? description;
  final String type; // e.g., 'Quiz', 'Assignment', 'Essay'
  const QuizInfoItem({
    required this.title,
    required this.subject,
    required this.date,
    required this.duration,
    required this.type,
    this.description,
  });
}

class QuizInfoPage extends StatefulWidget {
  const QuizInfoPage({super.key});

  @override
  State<QuizInfoPage> createState() => _QuizInfoPageState();
}

class _QuizInfoPageState extends State<QuizInfoPage> {
  late String _title;
  late String _subject;
  late String _date;
  late String _duration;
  late String _description;
  late String _type;

  double _clamp(double v, double min, double max) =>
      v < min ? min : (v > max ? max : v);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is QuizInfoItem) {
      _title = args.title;
      _subject = args.subject;
      _date = args.date;
      _duration = args.duration;
      _type = args.type; // <-- add this
      _description = args.description?.trim().isNotEmpty == true
          ? args.description!
          : _defaultDescription();
    } else if (args is Map) {
      _title = (args['title'] ?? '').toString();
      _subject = (args['subject'] ?? '').toString();
      _date = (args['date'] ?? '').toString();
      _duration = (args['duration'] ?? '').toString();
      _type = (args['type'] ?? '').toString(); // <-- add this
      _description = (args['description'] as String?)?.trim().isNotEmpty == true
          ? args['description'] as String
          : _defaultDescription();
    } else {
      _title = 'Quadratic Equations';
      _subject = 'Math Quiz 1';
      _date = 'Today, 3:00 PM';
      _duration = '20 min';
      _type = 'Quiz'; // <-- default
      _description = _defaultDescription();
    }
  }

  String _defaultDescription() => '''
This quiz helps you learn how to solve quadratic equations — those with an x² term — using simple, step-by-step methods.

You'll start by identifying the standard form:
ax² + bx + c = 0

Then, you'll explore four ways to solve them:
• Factoring (when numbers split easily)
• Using square roots (when there’s no bx term)
• Completing the square (to form a perfect square)
• The quadratic formula (a method that works every time)

You'll also learn about the discriminant (b² - 4ac), which tells you how many solutions there are — two, one, or none.

By the end of this quiz, you'll understand how to match the approach to the details of the problem and solve quickly with confidence.
''';

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;

    final padX = _clamp(w * 0.06, 16, 24);
    final titleSize = _clamp(w * 0.065, 20, 28);
    final aboutSize = _clamp(w * 0.050, 16, 20);
    final bodySize = _clamp(w * 0.040, 13, 15);

    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: GlobalAppBar(
        title: 'Quiz Info',
        showBack: true,
        onBack: () => Navigator.maybePop(context),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(padX, 12, padX, 24),
          children: [
            // --- Built-in Banner Card (matches your mock) ---
            _BannerCard(
              subject: _subject.isEmpty ? 'Math Quiz 1' : _subject,
              title: _title.isEmpty ? 'Quadratic Equations' : _title,
              type: _type, // <-- add this
            ),

            const SizedBox(height: 18),

            // --- About Heading ---
            Text(
              'About this Quiz',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                fontSize: aboutSize,
              ),
            ),
            const SizedBox(height: 8),

            // --- Body Copy ---
            Text(
              _description.trim(),
              style: textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: const Color(0xFF777777),
                fontSize: bodySize,
              ),
            ),
            const SizedBox(height: 20),

            // --- Meta (Date • Duration) ---
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: DefaultTextStyle(
                style: textTheme.bodyMedium!.copyWith(color: Colors.black87),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _date,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.access_time_outlined,
                      size: 18,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _duration,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // --- Sticky "Take Quiz" CTA ---
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.fromLTRB(padX, 8, padX, 12),
        child: SizedBox(
          height: 52,
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF234FF5), Color(0xFF142E8F)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.practiceQuizIntro);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent, // Make button transparent
                shadowColor: Colors.transparent, // Remove shadow
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Take Quiz',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: titleSize * 0.62,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Banner that always uses the built-in asset:
/// assets/images/assignments/assignment-icon.png
class _BannerCard extends StatelessWidget {
  final String subject;
  final String title;
  final String type;

  const _BannerCard({
    required this.subject,
    required this.title,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = _clamp(mq.size.height * 0.18, 128, 176);

    final leftPad = _clamp(w * 0.07, 20, 26); // increased left padding
    final imagePadding = _clamp(
      w * 0.04,
      12,
      18,
    ); // padding for top/right/bottom
    final subjectFs = _clamp(h * 0.12, 12, 15);
    final titleFs = _clamp(h * 0.28, 20, 28);

    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    return Container(
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x15000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF234FF5), Color(0xFF142E8F)],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // LEFT: subject + title
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: leftPad),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // subject + type (plain text, no pill)
                  Text(
                    '${subject.isEmpty ? "Mathematics" : subject} ${type.isEmpty ? "Quiz" : type}',
                    style: textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: subjectFs,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // title (wraps fully)
                  Text(
                    title.isEmpty ? 'Quadratic Equations' : title,
                    softWrap: true,
                    maxLines: null,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      height: 1.05,
                      fontSize: titleFs,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // RIGHT: large image filling height with padding
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                0,
                imagePadding * 0.01, // reduced from 0.2
                imagePadding * 0.1, // reduced from 0.6
                imagePadding * 0.01, // reduced from 0.2
              ),
              child: Image.asset(
                'assets/images/assignments/assignment-icon.png',
                fit: BoxFit.contain,
                height: h - imagePadding * 0.2, // increased from 0.5
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _clamp(double v, double min, double max) =>
      v < min ? min : (v > max ? max : v);
}
