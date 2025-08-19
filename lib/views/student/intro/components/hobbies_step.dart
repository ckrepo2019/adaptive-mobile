// lib/views/intro/components/hobbies_step.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'intro_theme.dart';
import 'typography.dart';

class HobbyChipData {
  final int id;
  final String label;
  const HobbyChipData({required this.id, required this.label});

  // Fallback defaults if backend is empty
  static List<HobbyChipData> defaults() => const [
    HobbyChipData(id: 1, label: 'Basketball'),
    HobbyChipData(id: 2, label: 'Soccer'),
    HobbyChipData(id: 3, label: 'Dancing'),
    HobbyChipData(id: 4, label: 'Writing'),
    HobbyChipData(id: 5, label: 'Volleyball'),
    HobbyChipData(id: 6, label: 'Journalism'),
    HobbyChipData(id: 7, label: 'Mobile Games'),
    HobbyChipData(id: 8, label: 'Others'),
  ];
}

/// Bigger, horizontally-scrollable 5-row masonry with ID-based selection.
class HobbiesStep extends StatelessWidget {
  const HobbiesStep({
    super.key,
    required this.hobbies, // List<HobbyChipData>
    required this.selectedIds, // Set<int>
    required this.onToggleId, // void Function(int)
    this.rows = 5,
    this.spacing = 14,
    this.chipHeight = 52,
    this.fontSize = 16,
    this.minRowGap = 6,
    this.maxRowGap = 12,
    this.neutralColor = const Color(0xFF94A3B8), // light gray
  });

  final List<HobbyChipData> hobbies;
  final Set<int> selectedIds;
  final void Function(int id) onToggleId;

  final int rows;
  final double spacing;
  final double chipHeight;
  final double fontSize;
  final double minRowGap;
  final double maxRowGap;
  final Color neutralColor;

  double _padFor(String s) {
    final len = s.length.clamp(1, 24);
    return _lerp(26, 16, (len - 1) / 23);
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  double _textWidth(BuildContext ctx, String text, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return tp.width;
  }

  @override
  Widget build(BuildContext context) {
    final items = hobbies.isEmpty ? HobbyChipData.defaults() : hobbies;
    final labelStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: neutralColor,
    );

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 90, 0, 0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final desiredGap = rows > 1
                    ? (constraints.maxHeight - rows * chipHeight) / (rows - 1)
                    : 0.0;
                final vGap = rows > 1
                    ? math.max(minRowGap, math.min(maxRowGap, desiredGap))
                    : 0.0;

                // shortest-row packing
                final rowWidths = List<double>.filled(rows, 0);
                final placed = <_PlacedChip>[];

                for (final item in items) {
                  final pad = _padFor(item.label);
                  final width =
                      _textWidth(context, item.label, labelStyle) + pad * 2;

                  // find shortest row
                  var row = 0;
                  var minW = rowWidths[0];
                  for (var r = 1; r < rows; r++) {
                    if (rowWidths[r] < minW) {
                      minW = rowWidths[r];
                      row = r;
                    }
                  }

                  placed.add(
                    _PlacedChip(
                      id: item.id,
                      label: item.label,
                      selected: selectedIds.contains(item.id),
                      left: rowWidths[row],
                      top: row * (chipHeight + vGap),
                      width: width,
                      pad: pad,
                      radius: chipHeight / 2,
                    ),
                  );

                  rowWidths[row] += width + spacing;
                }

                final totalWidth = (rowWidths..sort()).last;
                final totalHeight = rows * chipHeight + (rows - 1) * vGap;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: totalWidth,
                      maxWidth: totalWidth,
                      minHeight: totalHeight,
                      maxHeight: totalHeight,
                    ),
                    child: Stack(
                      children: [
                        for (final p in placed)
                          Positioned(
                            left: p.left,
                            top: p.top,
                            child: SizedBox(
                              width: p.width,
                              height: chipHeight,
                              child: _ChipPill(
                                text: p.label,
                                isSelected: p.selected,
                                hPad: p.pad,
                                radius: p.radius,
                                fontSize: fontSize,
                                neutralColor: neutralColor,
                                onTap: () => onToggleId(p.id),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // bottom description (unchanged)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: IntroTheme.blue,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: const DefaultTextStyle(
            style: TextStyle(color: Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                BodySmall("Let’s get to know each other", color: Colors.white),
                SizedBox(height: 8),
                TitleMedium(
                  "What are your\nFavorite Hobbies?",
                  color: Colors.white,
                ),
                SizedBox(height: 12),
                BodySmall(
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

class _ChipPill extends StatelessWidget {
  const _ChipPill({
    required this.text,
    required this.isSelected,
    required this.hPad,
    required this.radius,
    required this.fontSize,
    required this.neutralColor,
    required this.onTap,
  });

  final String text;
  final bool isSelected;
  final double hPad;
  final double radius;
  final double fontSize;
  final Color neutralColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = isSelected ? IntroTheme.blue : Colors.white;
    final fg = isSelected ? Colors.white : neutralColor;
    final border = isSelected ? Colors.transparent : neutralColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: hPad),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: border),
          ),
          child: Text(
            text,
            softWrap: false,
            overflow: TextOverflow.visible,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}

class _PlacedChip {
  _PlacedChip({
    required this.id,
    required this.label,
    required this.selected,
    required this.left,
    required this.top,
    required this.width,
    required this.pad,
    required this.radius,
  });

  final int id;
  final String label;
  final bool selected;
  final double left;
  final double top;
  final double width;
  final double pad;
  final double radius;
}
