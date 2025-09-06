
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Your existing imports
import 'package:Adaptive/widgets/app_bar.dart'; // GlobalAppBar

// This is your InkCardShell
class InkCardShell extends StatelessWidget {
  final Widget child;
  final Color leftAccent;
  final VoidCallback? onTap;

  const InkCardShell({
    super.key,
    required this.child,
    required this.leftAccent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border(left: BorderSide(color: leftAccent, width: 3)),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ======= PAGE =======
class LearningMaterialsPage extends StatefulWidget {
  const LearningMaterialsPage({super.key});

  @override
  State<LearningMaterialsPage> createState() => _LearningMaterialsPageState();
}

class _LearningMaterialsPageState extends State<LearningMaterialsPage> {
  final List<LessonSection> _sections = [
    LessonSection(
      title: 'Lesson 1: What Is Algebra?',
      totalTasks: 5,
      enabled: true,
      items: [
        MaterialItem(title: 'Topic 1: Definition of Algebra', enabled: true),
        MaterialItem(title: 'Variables and Constants', enabled: true),
        MaterialItem(title: 'Quiz 1 : Write simple algebraic expressions', enabled: true),
        MaterialItem(title: 'Identifying variables and constants', enabled: true),
        MaterialItem(title: 'Algebraic Expressions vs. Numerical Expressions', enabled: true),
      ],
    ),
    LessonSection(
      title: 'Lesson 2: The Language of Algebra',
      totalTasks: 5,
      enabled: true,
      items: [
        MaterialItem(title: 'Topic 1 : Definition of Algebra', enabled: false),
        MaterialItem(title: 'Quiz 1 : Write simple', enabled: false),
        MaterialItem(title: 'Practice Set', enabled: true),
      ],
    ),
  ];

  void _toggleSection(int sectionIndex, bool value) {
    setState(() {
      _sections[sectionIndex] = _sections[sectionIndex].copyWith(enabled: value);
    });
  }

  void _toggleItem(int sectionIndex, int itemIndex, bool value) {
    final section = _sections[sectionIndex];
    final items = [...section.items];
    items[itemIndex] = items[itemIndex].copyWith(enabled: value);
    setState(() {
      _sections[sectionIndex] = section.copyWith(items: items);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = GoogleFonts.poppinsTextTheme(theme.textTheme);

    return Theme(
      data: theme.copyWith(textTheme: textTheme),
      child: Scaffold(
        appBar: GlobalAppBar(title: 'Learning Materials', showBack: true),
        body: SafeArea(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _sections.length,
            itemBuilder: (context, sectionIndex) {
              final section = _sections[sectionIndex];
              return InkCardShell(
                leftAccent: section.enabled
                    ? Colors.black
                    : Colors.grey.shade400,
                onTap: () {
                  // You can expand/collapse or navigate
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            section.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Switch.adaptive(
                          value: section.enabled,
                          onChanged: (v) => _toggleSection(sectionIndex, v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${section.totalTasks} Total Task',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Items
                    ...List.generate(section.items.length, (i) {
                      final item = section.items[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                            Switch.adaptive(
                              value: item.enabled,
                              onChanged: (v) => _toggleItem(sectionIndex, i, v),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ======= MODELS =======
class LessonSection {
  final String title;
  final int totalTasks;
  final bool enabled;
  final List<MaterialItem> items;

  LessonSection({
    required this.title,
    required this.totalTasks,
    required this.enabled,
    required this.items,
  });

  LessonSection copyWith({
    String? title,
    int? totalTasks,
    bool? enabled,
    List<MaterialItem>? items,
  }) {
    return LessonSection(
      title: title ?? this.title,
      totalTasks: totalTasks ?? this.totalTasks,
      enabled: enabled ?? this.enabled,
      items: items ?? this.items,
    );
  }
}

class MaterialItem {
  final String title;
  final bool enabled;

  MaterialItem({required this.title, required this.enabled});

  MaterialItem copyWith({String? title, bool? enabled}) {
    return MaterialItem(
      title: title ?? this.title,
      enabled: enabled ?? this.enabled,
    );
  }
}
