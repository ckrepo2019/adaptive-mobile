import 'dart:async';
import 'dart:ui' as ui;
import 'package:color_palette_generator/color_palette_generator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Which layout to render
enum CardVariant { assignment, progress }

/// Assignment item model
class AssignmentItem {
  final String title;
  final String subject;
  final String date; // "Today, 3:00 PM"
  final String duration; // "20 min"
  const AssignmentItem({
    required this.title,
    required this.subject,
    required this.date,
    required this.duration,
  });
}

/// Class progress item model
class ClassProgressItem {
  final String title;
  final int firstHierarchy;
  final int secondHierarchy;

  final String firstHierarchyLabel; // e.g., "Chapters"
  final String secondHierarchyLabel; // e.g., "Units"

  /// 0..1
  final double progress;
  final String iconAsset;
  final Color accent;

  const ClassProgressItem({
    required this.title,
    required this.firstHierarchy,
    required this.secondHierarchy,
    required this.firstHierarchyLabel,
    required this.secondHierarchyLabel,
    required this.progress,
    required this.iconAsset,
    this.accent = Colors.redAccent,
  });
}

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

  const CardsList({
    super.key,
    required this.headerTitle,
    required this.headerIcon, // dynamic now
    required this.items,
    required this.variant,
    this.ctaLabel,
    this.onCta,
    this.padding,
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
                return _AssignmentCard(item: item as AssignmentItem);
              case CardVariant.progress:
                return _ClassProgressCard(item: item as ClassProgressItem);
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

/// Shared card container (rounded, left accent, soft shadow)
class _CardShell extends StatelessWidget {
  final Widget child;
  final Color leftAccent;
  const _CardShell({required this.child, required this.leftAccent});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
    );
  }
}

/// Assignment card content
class _AssignmentCard extends StatelessWidget {
  final AssignmentItem item;
  const _AssignmentCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      leftAccent: Colors.redAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
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

const String kDefaultSubjectIcon =
    'assets/images/student-home/default-class.png';

/// Class progress card content

class _ClassProgressCard extends StatefulWidget {
  final ClassProgressItem item;
  const _ClassProgressCard({required this.item});

  @override
  State<_ClassProgressCard> createState() => _ClassProgressCardState();
}

ImageProvider<Object> _imageProviderFor(String path) {
  final p = path.trim();
  if (p.startsWith('http://') || p.startsWith('https://')) {
    return NetworkImage(p);
  }
  return AssetImage(p);
}

// For UI display in the tile (RETURNS Widget)
bool _isNetworkPath(String p) =>
    p.startsWith('http://') || p.startsWith('https://');

Widget _buildIconImage(String path, {double w = 26, double h = 26}) {
  if (_isNetworkPath(path)) {
    return Image.network(
      path,
      width: w,
      height: h,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Image.asset(
        kDefaultSubjectIcon,
        width: w,
        height: h,
        fit: BoxFit.contain,
      ),
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : const SizedBox.shrink(),
      gaplessPlayback: true,
      filterQuality: FilterQuality.low,
    );
  }
  return Image.asset(path, width: w, height: h, fit: BoxFit.contain);
}

class _ClassProgressCardState extends State<_ClassProgressCard> {
  static final Map<String, bool> _assetOkCache = {};
  late String _iconPath; // asset path or URL; always valid after init
  late Color _accent; // computed from image, fallback to item.accent

  @override
  void initState() {
    super.initState();

    // Start with provided path or default icon
    final provided = widget.item.iconAsset.trim();
    _iconPath = provided.isNotEmpty ? provided : kDefaultSubjectIcon;

    // Fallback accent first (we'll try to compute from image next)
    _accent = widget.item.accent;

    // If it's an asset path, verify it exists; if not, fallback to default
    if (!(_iconPath.startsWith('http://') ||
        _iconPath.startsWith('https://'))) {
      _upgradeIfExists(_iconPath);
    }

    // Try to compute an accent color from the image (asset or network)
    _computeAccentFromImage(_iconPath);
  }

  Future<void> _upgradeIfExists(String path) async {
    final cached = _assetOkCache[path];
    if (cached == true) return;
    if (cached == false) {
      if (mounted) setState(() => _iconPath = kDefaultSubjectIcon);
      return;
    }
    try {
      await rootBundle.load(path);
      _assetOkCache[path] = true;
    } catch (_) {
      _assetOkCache[path] = false;
      if (mounted) setState(() => _iconPath = kDefaultSubjectIcon);
    }
  }

  /// Lightweight "dominant" color extractor (averages non‑transparent pixels).
  /// We sample a small version for speed.
  Future<void> _computeAccentFromImage(String path) async {
    try {
      final provider = _imageProviderFor(path);

      // Downsize to ~48x48 so we don't process large images
      final resized = provider is ResizeImage
          ? provider
          : ResizeImage(
              provider as ImageProvider<Object>,
              width: 48,
              height: 48,
            );

      final uiImage = await _loadUiImage(resized);
      final byteData = await uiImage.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      int r = 0, g = 0, b = 0, a = 0, count = 0;

      for (int i = 0; i + 3 < bytes.length; i += 4) {
        final rr = bytes[i]; // R
        final gg = bytes[i + 1]; // G
        final bb = bytes[i + 2]; // B
        final aa = bytes[i + 3]; // A

        if (aa < 16) continue; // skip near‑transparent
        r += rr;
        g += gg;
        b += bb;
        a += aa;
        count++;
      }

      if (count == 0) return;

      final c = Color.fromARGB(
        (a ~/ count).clamp(0, 255),
        r ~/ count,
        g ~/ count,
        b ~/ count,
      );

      if (mounted) setState(() => _accent = c);
    } catch (_) {
      // Keep fallback accent silently
    }
  }

  Future<ui.Image> _loadUiImage(ImageProvider provider) {
    final completer = Completer<ui.Image>();
    final stream = provider.resolve(const ImageConfiguration());
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (ImageInfo info, bool _) {
        completer.complete(info.image);
        stream.removeListener(listener);
      },
      onError: (Object error, StackTrace? stackTrace) {
        completer.completeError(error, stackTrace);
        stream.removeListener(listener);
      },
    );
    stream.addListener(listener);
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final p = item.progress.clamp(0.0, 1.0);

    return _CardShell(
      leftAccent: _accent,
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
            alignment: Alignment.center,
            child: _buildIconImage(_iconPath, w: 48, h: 48),
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
                      '${(p * 100).round()}%',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Progress bar + knob
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
                  '${item.firstHierarchy} ${item.firstHierarchyLabel} • '
                  '${item.secondHierarchy} ${item.secondHierarchyLabel}',
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
