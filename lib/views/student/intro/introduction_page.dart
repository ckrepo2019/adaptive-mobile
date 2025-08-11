import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lms/config/routes.dart';
import 'intro_layout.dart';

class IntroductionPage extends StatefulWidget {
  const IntroductionPage({super.key});

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  // ---- Config ----
  static const int totalPages = 4; // 0..3

  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Step logic for page 1 (index 1)
  int _stepInPage1 = 0;

  // Optional: selected hobbies state (for the chip screen)
  final Set<String> _selectedHobbies = {};

  // Data we fetch from route args
  Map<String, dynamic>? _studentHomeData;
  String? _token, _uid;
  int? _userType;

  // Hobbies coming from backend (flattened names)
  List<String> _backendHobbies = const [];

  bool _printed = false;

  // Colors
  static const Color kBlue = Color(0xFF0055FF);
  static const Color kText = Color(0xFF0F172A); // slate-900
  static const Color kSubText = Color(0xFF334155); // slate-700
  static const double kHPad = 24;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Chunked logger so Logcat doesn't truncate long JSON
  void _logLarge(Object obj, {int chunk = 900}) {
    final s = obj is String
        ? obj
        : const JsonEncoder.withIndent('  ').convert(obj);
    for (var i = 0; i < s.length; i += chunk) {
      debugPrint(s.substring(i, math.min(i + chunk, s.length)));
    }
  }

  // Pull hobby names from studentHomeData['hobbies_type'][*]['hobbies'][*]['name']
  List<String> _extractHobbyNames(Map<String, dynamic> d) {
    final types = (d['hobbies_type'] as List?)?.cast<dynamic>() ?? const [];
    final out = <String>[];
    for (final t in types) {
      final tm = (t as Map).cast<String, dynamic>();
      final hs = (tm['hobbies'] as List?)?.cast<dynamic>() ?? const [];
      for (final h in hs) {
        final hm = (h as Map).cast<String, dynamic>();
        final name = (hm['name'] ?? '').toString().trim();
        if (name.isNotEmpty) out.add(name);
      }
    }
    // Deduplicate while preserving order
    final seen = <String>{};
    return out.where((e) => seen.add(e)).toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_printed) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      if (args['studentHomeData'] is Map) {
        _studentHomeData = Map<String, dynamic>.from(
          args['studentHomeData'] as Map,
        );
        _backendHobbies = _extractHobbyNames(_studentHomeData!);
      }
      _token = args['token'] as String?;
      _uid = args['uid'] as String?;
      _userType = args['userType'] as int?;
    }

    // Print once after the first frame so it doesn't spam on rebuilds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_printed) return;
      _printed = true;

      if (_studentHomeData == null) {
        debugPrint('[Intro] No studentHomeData received. args=$args');
        return;
      }

      final d = _studentHomeData!;
      // Quick sanity prints (small, always visible)
      debugPrint('[Intro] ✅ studentHomeData received.');
      debugPrint('[Intro] keys: ${d.keys.toList()}');
      debugPrint(
        '[Intro] enrollment_data: ${jsonEncode(d['enrollment_data'])}',
      );
      debugPrint(
        '[Intro] subjects=${(d['subjects'] as List?)?.length ?? 0}, '
        'hobbyTypes=${(d['hobbies_type'] as List?)?.length ?? 0}, '
        'learnersProfile=${(d['learners_profile'] as List?)?.length ?? 0}, '
        'questions=${(d['learner_questions'] as List?)?.length ?? 0}',
      );
      debugPrint('[Intro] backendHobbies=${_backendHobbies.length}');

      // Full pretty JSON (chunked)
      debugPrint('----- Intro: full studentHomeData -----');
      _logLarge(d);
      debugPrint('----- end studentHomeData -----');
    });
  }

  void _nextPage() {
    // Page 1: two-step behavior
    if (_currentPage == 1 && _stepInPage1 == 0) {
      setState(() => _stepInPage1 = 1);
      return;
    }

    if (_currentPage < totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Last page → go to analyzing
      Navigator.pushReplacementNamed(context, AppRoutes.analyzing);
    }
  }

  void _onThumbSelect(bool isUp) {
    // Hook for thumb up/down answers
  }

  @override
  Widget build(BuildContext context) {
    final bool _isHobbyGrid = (_currentPage == 1 && _stepInPage1 == 1);
    final Color _uiOnBg = _isHobbyGrid
        ? kBlue
        : Colors.white; // blue on white page, white on blue pages
    final Color _dotInactive = _isHobbyGrid
        ? const Color(0xFFE2E8F0)
        : Colors.white.withAlpha(0x35);
    return Scaffold(
      backgroundColor: kBlue, // ✅ whole page is white now
      body: SafeArea(
        child: Stack(
          children: [
            // Pages
            PageView.builder(
              controller: _pageController,
              itemCount: totalPages,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                  if (index != 1) {
                    _stepInPage1 = 0; // reset step if leaving page 1
                  }
                });
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 100,
                  ), // no left/right padding
                  child: _buildPage(index),
                );
              },
            ),

            // Dot Indicator
            Positioned(
              bottom: 30,
              left: 0, // no page padding
              child: Row(
                children: List.generate(totalPages, (index) {
                  final isActive = index == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(right: 6),
                    height: 8,
                    width: isActive ? 24 : 8,
                    decoration: BoxDecoration(
                      color: isActive ? _uiOnBg : _dotInactive,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                }),
              ),
            ),

            // Next / Let's Go button
            Positioned(
              bottom: 24,
              right: 0, // no page padding
              child: GestureDetector(
                onTap: _nextPage,
                child: Row(
                  children: [
                    Text(
                      (_currentPage == totalPages - 1) ? "Let's Go" : 'Next',
                      style: TextStyle(
                        color: _uiOnBg,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      (_currentPage == totalPages - 1)
                          ? Icons.check_circle_outline
                          : Icons.double_arrow,
                      color: _uiOnBg,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Pages ----
  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return Container(
          color: kBlue,
          child: const _CenteredColumn(
            children: [
              Spacer(),
              _TitleSmall(
                'Welcome to your adaptive learning.',
                color: Colors.white,
              ),
              SizedBox(height: 10),
              _TitleLarge('Learn smarter\nNot Harder!', color: Colors.white),
              Spacer(),
            ],
          ),
        );

      case 1:
        if (_stepInPage1 == 0) {
          return Container(
            color: kBlue,
            child: const _CenteredColumn(
              children: [
                Spacer(),
                _TitleLarge('Getting Started', color: Colors.white),
                SizedBox(height: 10),
                _BodySmall(
                  'Before we start, please take a moment to\n'
                  'complete our assessment questionnaire.\n'
                  'This will help us understand your learning\n'
                  'style and create a personalized\n'
                  'experience just for you.',
                  color: Colors.white,
                ),
                Spacer(),
              ],
            ),
          );
        }
        final hobbies = _backendHobbies.isNotEmpty
            ? _backendHobbies
            : _HobbiesStep.defaultHobbies;
        return _HobbiesStep(
          hobbies: hobbies,
          selected: _selectedHobbies,
          onToggle: (hobby) {
            setState(() {
              if (_selectedHobbies.contains(hobby)) {
                _selectedHobbies.remove(hobby);
              } else {
                _selectedHobbies.add(hobby);
              }
            });
          },
        );

      case 2:
        return Container(
          color: kBlue,
          child: _ThumbsStep(
            header: "Let's get to know each other",
            question:
                'Do you learn best when\ninformation is presented\nin charts or diagrams?',
            onThumbUp: () => _onThumbSelect(true),
            onThumbDown: () => _onThumbSelect(false),
            textColor: Colors.white,
          ),
        );

      case 3:
      default:
        return Container(
          color: kBlue,
          child: _ThumbsStep(
            header: "Let's get to know each other",
            question:
                'Do you remember\ninformation better when you hear it spoken or\n discussed?',
            onThumbUp: () => _onThumbSelect(true),
            onThumbDown: () => _onThumbSelect(false),
            textColor: Colors.white,
          ),
        );
    }
  }
}

/// Reusable vertical layout with left alignment and safe spacing.
class _CenteredColumn extends StatelessWidget {
  final List<Widget> children;
  const _CenteredColumn({required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

/// Slide for hobbies (step 2 in page 1)
class _HobbiesStep extends StatelessWidget {
  const _HobbiesStep({
    required this.hobbies,
    required this.selected,
    required this.onToggle,
  });

  final List<String> hobbies; // <- pass _backendHobbies or defaults
  final Set<String> selected;
  final void Function(String hobby) onToggle;

  static const defaultHobbies = <String>[
    'Basketball',
    'Soccer',
    'Dancing',
    'Writing',
    'Volleyball',
    'Journalism',
    'Mobile Games',
    'Others',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // TOP: horizontally scrollable chips (white page)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: SizedBox(
              // ~5 rows * 44 height + gaps
              height: 260,
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5, // ← five rows
                  mainAxisSpacing: 10, // space between columns
                  crossAxisSpacing: 10, // space between rows
                  childAspectRatio: 2.8, // width / height of each chip
                ),
                itemCount: hobbies.length,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemBuilder: (_, i) {
                  final hobby = hobbies[i];
                  final isSelected = selected.contains(hobby);
                  return Material(
                    elevation: isSelected ? 1.5 : 0,
                    borderRadius: BorderRadius.circular(20),
                    child: FilterChip(
                      label: Text(hobby, overflow: TextOverflow.ellipsis),
                      selected: isSelected,
                      onSelected: (_) => onToggle(hobby),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : _IntroductionPageState.kText,
                      ),
                      backgroundColor: Colors.white,
                      selectedColor: _IntroductionPageState.kBlue,
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        // BOTTOM: description block (ONLY colored area)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: _IntroductionPageState.kBlue,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: const DefaultTextStyle(
            style: TextStyle(color: Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _BodySmall("Let’s get to know each other", color: Colors.white),
                SizedBox(height: 8),
                _TitleMedium(
                  "What are your\nFavorite Hobbies?",
                  color: Colors.white,
                ),
                SizedBox(height: 12),
                _BodySmall(
                  "Before we start, please take a moment to\n"
                  "complete our assessment questionnaire.\n"
                  "This will help us understand your learning style\n"
                  "and create a personalized experience just for you.",
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Slide for thumbs up/down questions
class _ThumbsStep extends StatelessWidget {
  const _ThumbsStep({
    required this.header,
    required this.question,
    required this.onThumbUp,
    required this.onThumbDown,
    this.textColor = _IntroductionPageState.kText,
  });

  final String header;
  final String question;
  final VoidCallback onThumbUp;
  final VoidCallback onThumbDown;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return const _CenteredColumn(children: [Spacer()]).copyWith(
      additional: [
        _BodySmall(header, color: textColor),
        SizedBox(height: 10),
        _TitleMedium(question, color: textColor),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ThumbButton(icon: Icons.thumb_up),
            SizedBox(width: 10),
            _ThumbButton(icon: Icons.thumb_down),
          ],
        ),
        Spacer(),
      ],
      onThumbUp: onThumbUp,
      onThumbDown: onThumbDown,
    );
  }
}

/// Typography helpers (dark by default; can override)
class _TitleSmall extends StatelessWidget {
  final String text;
  final Color color;
  const _TitleSmall(this.text, {this.color = _IntroductionPageState.kSubText});
  @override
  Widget build(BuildContext context) =>
      Text(text, style: TextStyle(color: color, fontSize: 14));
}

class _TitleLarge extends StatelessWidget {
  final String text;
  final Color color;
  const _TitleLarge(this.text, {this.color = _IntroductionPageState.kText});
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      color: color,
      fontSize: 40,
      fontWeight: FontWeight.bold,
      letterSpacing: 2,
      height: 1.2,
    ),
  );
}

class _TitleMedium extends StatelessWidget {
  final String text;
  final Color color;
  const _TitleMedium(this.text, {this.color = _IntroductionPageState.kText});
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      color: color,
      fontSize: 30,
      fontWeight: FontWeight.bold,
      height: 1.25,
    ),
  );
}

class _BodySmall extends StatelessWidget {
  final String text;
  final Color color;
  const _BodySmall(this.text, {this.color = _IntroductionPageState.kSubText});
  @override
  Widget build(BuildContext context) =>
      Text(text, style: TextStyle(color: color, fontSize: 12));
}

/// Thumbs button with local visual state
class _ThumbButton extends StatefulWidget {
  final IconData icon;
  const _ThumbButton({required this.icon});

  @override
  State<_ThumbButton> createState() => _ThumbButtonState();
}

class _ThumbButtonState extends State<_ThumbButton> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => _isSelected = !_isSelected),
      child: Container(
        height: 50,
        width: 150,
        decoration: BoxDecoration(
          color: _isSelected ? _IntroductionPageState.kBlue : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _IntroductionPageState.kBlue, width: 1),
        ),
        child: Center(
          child: Icon(
            widget.icon,
            color: _isSelected ? Colors.white : _IntroductionPageState.kBlue,
          ),
        ),
      ),
    );
  }
}

// ------- small utility to extend _CenteredColumn with extra children -------
extension on _CenteredColumn {
  Widget copyWith({
    List<Widget>? additional,
    VoidCallback? onThumbUp,
    VoidCallback? onThumbDown,
  }) {
    final kids = List<Widget>.from(children);
    if (additional != null) kids.addAll(additional);

    // Replace the static thumb row when callbacks are provided
    for (var i = 0; i < kids.length; i++) {
      final w = kids[i];
      if (w is Row &&
          w.children.length == 3 &&
          w.children.first is _ThumbButton) {
        kids[i] = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: onThumbUp,
              child: const _ThumbButton(icon: Icons.thumb_up),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onThumbDown,
              child: const _ThumbButton(icon: Icons.thumb_down),
            ),
          ],
        );
      }
    }

    return _CenteredColumn(children: kids);
  }
}
