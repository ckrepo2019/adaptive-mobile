import 'package:flutter/material.dart';
import 'package:flutter_lms/config/routes.dart';

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

  static const Color kBlue = Color(0xFF0055FF);
  static const double kHPad = 24;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
    // Hook if you need to do anything with thumb up/down answers
    // debugPrint('Thumb ${isUp ? 'UP' : 'DOWN'} on page $_currentPage');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBlue,
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
                  if (index != 1)
                    _stepInPage1 = 0; // reset step if leaving page 1
                });
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(kHPad, 0, kHPad, 100),
                  child: _buildPage(index),
                );
              },
            ),

            // Dot Indicator
            Positioned(
              bottom: 30,
              left: kHPad,
              child: Row(
                children: List.generate(totalPages, (index) {
                  final isActive = index == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(right: 6),
                    height: 8,
                    width: isActive ? 24 : 8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                }),
              ),
            ),

            // Next / Let's Go button
            Positioned(
              bottom: 24,
              right: 24,
              child: GestureDetector(
                onTap: _nextPage,
                child: Row(
                  children: [
                    Text(
                      (_currentPage == totalPages - 1) ? "Let's Go" : 'Next',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      (_currentPage == totalPages - 1)
                          ? Icons.check_circle_outline
                          : Icons.double_arrow,
                      color: Colors.white,
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
        return const _CenteredColumn(
          children: [
            Spacer(),
            _TitleSmall('Welcome to your adaptive learning.'),
            SizedBox(height: 10),
            _TitleLarge('Learn smarter\nNot Harder!'),
            Spacer(),
          ],
        );
      case 1:
        if (_stepInPage1 == 0) {
          return const _CenteredColumn(
            children: [
              Spacer(),
              _TitleLarge('Getting Started'),
              SizedBox(height: 10),
              _BodySmall(
                'Before we start, please take a moment to\n'
                'complete our assessment questionnaire.\n'
                'This will help us understand your learning\n'
                'style and create a personalized\n'
                'experience just for you.',
              ),
              Spacer(),
            ],
          );
        }
        return _HobbiesStep(
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
        return _ThumbsStep(
          header: "Let's get to know each other",
          question:
              'Do you learn best when\ninformation is presented\nin charts or diagrams?',
          onThumbUp: () => _onThumbSelect(true),
          onThumbDown: () => _onThumbSelect(false),
        );
      case 3:
      default:
        return _ThumbsStep(
          header: "Let's get to know each other",
          // fixed typos: "hea it" → "hear it"
          question:
              'Do you remember\ninformation better when you hear it spoken or\ndiscussed?',
          onThumbUp: () => _onThumbSelect(true),
          onThumbDown: () => _onThumbSelect(false),
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
  _HobbiesStep({required this.selected, required this.onToggle});

  final Set<String> selected;
  final void Function(String hobby) onToggle;

  static const hobbies = <String>[
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
        // Scrollable chips
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(0, 60, 0, 24),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: hobbies.map((hobby) {
                final isSelected = selected.contains(hobby);
                return FilterChip(
                  label: Text(hobby),
                  selected: isSelected,
                  onSelected: (_) => onToggle(hobby),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                  backgroundColor: Colors.white,
                  selectedColor: Colors.blue.shade900,
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Colors.grey),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Bottom text block
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: _IntroductionPageState.kBlue,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _BodySmall("Let’s get to know each other"),
              SizedBox(height: 8),
              _TitleMedium("What are your\nFavorite Hobbies?"),
              SizedBox(height: 12),
              _BodySmall(
                "Before we start, please take a moment to\n"
                "complete our assessment questionnaire.\n"
                "This will help us understand your learning style\n"
                "and create a personalized experience just for you.",
              ),
            ],
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
  });

  final String header;
  final String question;
  final VoidCallback onThumbUp;
  final VoidCallback onThumbDown;

  @override
  Widget build(BuildContext context) {
    return const _CenteredColumn(children: [Spacer()]).copyWith(
      additional: [
        _BodySmall(header),
        const SizedBox(height: 10),
        _TitleMedium(question),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ThumbButton(icon: Icons.thumb_up),
            SizedBox(width: 10),
            _ThumbButton(icon: Icons.thumb_down),
          ],
        ),
        const Spacer(),
      ],
      onThumbUp: onThumbUp,
      onThumbDown: onThumbDown,
    );
  }
}

/// Typography helpers
class _TitleSmall extends StatelessWidget {
  final String text;
  const _TitleSmall(this.text);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: const TextStyle(color: Colors.white, fontSize: 14));
}

class _TitleLarge extends StatelessWidget {
  final String text;
  const _TitleLarge(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 40,
      fontWeight: FontWeight.bold,
      letterSpacing: 2,
      height: 1.2,
    ),
  );
}

class _TitleMedium extends StatelessWidget {
  final String text;
  const _TitleMedium(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 30,
      fontWeight: FontWeight.bold,
      height: 1.25,
    ),
  );
}

class _BodySmall extends StatelessWidget {
  final String text;
  const _BodySmall(this.text);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: const TextStyle(color: Colors.white, fontSize: 12));
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
          color: _isSelected ? Colors.blue.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: const BorderSide(color: _IntroductionPageState.kBlue),
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
