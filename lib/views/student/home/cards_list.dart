import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_lms/utils/dominant_color_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../../models/items.dart';
import '../../../utils/image_utils.dart';
import '../../../utils/progress_utils.dart';
import '../../../utils/assignment_utils.dart';
import '../../../widgets/ui_widgets.dart';
import '../../../utils/palette_utils.dart';

/// Which layout to render
enum CardVariant { assignment, progress }

/// Default subject icon for fallbacks (project-specific path).
const String kDefaultSubjectIcon =
    'assets/images/student-home/default-class.png';

/// Reusable list section widget for BOTH Assignments & Class Progress
class CardsList<T> extends StatelessWidget {
  final String headerTitle;

  /// You can pass either an IconData or a String (asset path)
  final dynamic headerIcon;

  final List<T> items;
  final CardVariant variant;
  final String? ctaLabel;
  final VoidCallback? onCta;
  final EdgeInsetsGeometry? padding;

  /// optional item tap callbacks
  final void Function(AssignmentItem item)? onAssignmentTap;
  final void Function(ClassProgressItem item)? onProgressTap;

  const CardsList({
    super.key,
    required this.headerTitle,
    required this.headerIcon,
    required this.items,
    required this.variant,
    this.ctaLabel,
    this.onCta,
    this.padding,
    this.onAssignmentTap,
    this.onProgressTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget iconWidget;
    if (headerIcon is IconData) {
      iconWidget = Icon(headerIcon as IconData, color: Colors.black87);
    } else if (headerIcon is String) {
      iconWidget = Image.asset(
        headerIcon as String,
        width: 25,
        height: 25,
        fit: BoxFit.contain,
      );
    } else {
      iconWidget = const SizedBox.shrink();
    }
    final _usedAccents = <int>{};

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              iconWidget,
              const SizedBox(width: 8),
              Text(
                headerTitle,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...List.generate(items.length, (i) {
            final item = items[i];
            switch (variant) {
              case CardVariant.assignment:
                return _AssignmentCard(
                  item: item as AssignmentItem,
                  onTap: onAssignmentTap,
                );
              case CardVariant.progress:
                return _ClassProgressCard(
                  item: item as ClassProgressItem,
                  onTap: onProgressTap,
                  usedAccents: _usedAccents, // NEW
                );
            }
          }),

          if (ctaLabel != null) ...[
            const SizedBox(height: 8),
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
                onPressed: onCta,
                child: Text(
                  ctaLabel!,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Assignment card content
class _AssignmentCard extends StatelessWidget {
  final AssignmentItem item;
  final void Function(AssignmentItem item)? onTap;

  const _AssignmentCard({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkCardShell(
      leftAccent: Colors.redAccent,
      onTap: onTap == null ? null : () => onTap!(item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Combined subject + type + title in one line (reusable helper)
          Text(
            assignmentTitleLine(item),
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: null,
            overflow: TextOverflow.ellipsis,
          ),

          Text(
            item.subject,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: Colors.black54,
              ),
              const SizedBox(width: 4),
              Text(
                item.date,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.access_time_outlined,
                size: 14,
                color: Colors.black54,
              ),
              const SizedBox(width: 4),
              Text(
                item.duration,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, size: 18, color: Colors.black54),
            ],
          ),
        ],
      ),
    );
  }
}

/// Class progress card content
class _ClassProgressCard extends StatefulWidget {
  final ClassProgressItem item;
  final void Function(ClassProgressItem item)? onTap;
  final Set<int>? usedAccents;
  const _ClassProgressCard({required this.item, this.onTap, this.usedAccents});

  @override
  State<_ClassProgressCard> createState() => _ClassProgressCardState();
}

class _ClassProgressCardState extends State<_ClassProgressCard> {
  static final Map<String, bool> _assetOkCache = {};
  late String _iconPath;
  late Color _accent;

  static const String kDefaultFallback =
      'assets/images/default-images/default-classes.jpg';

  @override
  void initState() {
    super.initState();
    _initFromItem();
  }

  @override
  void didUpdateWidget(covariant _ClassProgressCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the bound item changes (list recycling), re-init/recompute
    if (oldWidget.item.iconAsset != widget.item.iconAsset) {
      _initFromItem();
    }
  }

  void _initFromItem() {
    final provided = widget.item.iconAsset.trim();
    _iconPath = provided.isNotEmpty ? provided : kDefaultFallback;
    _accent = widget.item.accent;

    if (!isNetworkPath(_iconPath)) {
      _upgradeIfExists(_iconPath);
    }
    _computeAccentFromImage(_iconPath);
  }

  Future<void> _upgradeIfExists(String path) async {
    final cached = _assetOkCache[path];
    if (cached == true) return;

    if (cached == false) {
      if (mounted) {
        setState(() => _iconPath = kDefaultFallback);
        // ⬇️ Recompute for fallback immediately
        _computeAccentFromImage(kDefaultFallback);
      }
      return;
    }

    try {
      await rootBundle.load(path);
      _assetOkCache[path] = true;
    } catch (_) {
      _assetOkCache[path] = false;
      if (mounted) {
        setState(() => _iconPath = kDefaultFallback);
        // ⬇️ Recompute for fallback immediately
        _computeAccentFromImage(kDefaultFallback);
      }
    }
  }

  Future<void> _computeAccentFromImage(String path) async {
    // Get a small palette (top 5)
    final palette = await PaletteUtils.paletteFromPath(path, maxColors: 5);
    if (!mounted) return;

    // If no palette, keep existing accent
    if (palette.isEmpty) return;

    // Choose a distinct color vs. already-used accents in this section
    final chosen = PaletteUtils.pickDistinct(
      palette,
      widget.usedAccents ?? const <int>{},
      minDistance: 40, // tweak if you want stricter separation
    );

    if (chosen != null && mounted) {
      setState(() => _accent = chosen);
      // Register this color as used (RGB only)
      widget.usedAccents?.add(PaletteUtils.rgbKey(chosen));
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final p = clamp01(item.progress);

    return InkCardShell(
      leftAccent: _accent,
      onTap: widget.onTap == null ? null : () => widget.onTap!(item),
      child: Row(
        children: [
          // Icon tile
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image(
              image: imageProviderFor(_iconPath),
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) {
                // If network/asset fails at render time, switch to fallback AND recompute accent.
                if (_iconPath != kDefaultFallback) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    setState(() => _iconPath = kDefaultFallback);
                    _computeAccentFromImage(kDefaultFallback);
                  });
                }
                return Image.asset(kDefaultFallback, fit: BoxFit.cover);
              },
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Text(
                      percentText(p),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Progress bar
                SizedBox(
                  height: 12,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: p,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: _accent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment((p * 2) - 1, 0),
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.10),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(color: _accent, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // Dynamic labels
                Text(
                  twoLevelLabel(
                    item.firstHierarchy,
                    item.firstHierarchyLabel,
                    item.secondHierarchy,
                    item.secondHierarchyLabel,
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
