import 'package:flutter/material.dart';

/// Dot row + "Next" CTA used across intro pages
class IntroFooter extends StatelessWidget {
  const IntroFooter({
    super.key,
    required this.total,
    required this.current,
    required this.onNext,
    required this.activeColor,
    required this.inactiveColor,
    required this.textColor,
    this.isLast = false,
    this.onDotTap,
    this.maxVisibleDots = 4, // show up to N dots
    this.anchorIndex = 2, // keep current at this position (3rd dot)
    this.anchorActiveFrom = 4, // start anchoring when current >= 4
  });

  final int total;
  final int current;
  final VoidCallback onNext;
  final Color activeColor;
  final Color inactiveColor;
  final Color textColor;
  final bool isLast;

  /// Called with the tapped dot index. Parent can decide what to do.
  final void Function(int index)? onDotTap;

  /// Windowing/anchoring controls
  final int maxVisibleDots;
  final int anchorIndex; // 0-based position within the window
  final int anchorActiveFrom; // start anchoring at this current index

  @override
  Widget build(BuildContext context) {
    final indices = _visibleIndicesAnchored(
      total: total,
      current: current,
      maxVisible: maxVisibleDots,
      anchorIndex: anchorIndex,
      anchorActiveFrom: anchorActiveFrom,
    );

    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24),
      child: Stack(
        children: [
          // Dots (windowed + anchored)
          Positioned(
            left: 0,
            bottom: 30,
            child: Row(
              children: [
                for (final i in indices) ...[
                  InkWell(
                    onTap: () => onDotTap?.call(i),
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(right: 6),
                      height: 8,
                      width: i == current ? 24 : 8, // pill for active
                      decoration: BoxDecoration(
                        color: i == current ? activeColor : inactiveColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Next
          Positioned(
            right: 0,
            bottom: 24,
            child: InkWell(
              onTap: onNext,
              child: Row(
                children: [
                  Text(
                    isLast ? "Let's Go" : 'Next',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isLast ? Icons.check_circle_outline : Icons.double_arrow,
                    color: textColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Visible indices with anchoring:
  /// - If total <= maxVisible: show all.
  /// - If current < anchorActiveFrom: show the first [maxVisible] dots (no shift).
  /// - Else: keep the current index at [anchorIndex] within the window,
  ///   clamping at the end so the last page is visible.
  List<int> _visibleIndicesAnchored({
    required int total,
    required int current,
    required int maxVisible,
    required int anchorIndex,
    required int anchorActiveFrom,
  }) {
    if (total <= maxVisible) {
      return List<int>.generate(total, (i) => i);
    }

    // Initial window (no anchoring yet)
    if (current < anchorActiveFrom) {
      return List<int>.generate(maxVisible, (i) => i);
    }

    // Anchor current at anchorIndex (e.g., 2 => the 3rd dot)
    int start = current - anchorIndex;
    int end = start + maxVisible - 1;

    // Clamp to the tail
    if (end > total - 1) {
      end = total - 1;
      start = end - maxVisible + 1;
    }

    // Clamp to the head just in case
    if (start < 0) {
      start = 0;
      end = start + maxVisible - 1;
    }

    return List<int>.generate(end - start + 1, (i) => start + i);
  }
}
