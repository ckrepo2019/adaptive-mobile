import 'package:flutter/material.dart';
import 'package:flutter_lms/widgets/base_widgets.dart';
import 'package:flutter_lms/utils/dominant_color_utils.dart';
import 'package:flutter_lms/utils/palette_utils.dart';

class GlobalSubjectWidget extends BaseWidget {
  final String classCode;
  final String subject;
  final String time; // e.g., "Today, M, T, W • 8:00–9:30 AM"
  final String teacherName; // full name or 'TBA'
  final String? imageUrl;

  const GlobalSubjectWidget({
    super.key,
    required this.classCode,
    required this.time,
    required this.teacherName,
    required this.subject,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return _SubjectCard(
      classCode: classCode,
      subject: subject,
      time: time,
      teacherName: teacherName,
      imageUrl: imageUrl,
    );
  }
}

class _SubjectCard extends StatefulWidget {
  final String classCode;
  final String subject;
  final String time;
  final String teacherName;
  final String? imageUrl;

  const _SubjectCard({
    required this.classCode,
    required this.subject,
    required this.time,
    required this.teacherName,
    required this.imageUrl,
  });

  @override
  State<_SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<_SubjectCard> {
  Color _sideColor = const Color(0xFFFFD400); // fallback yellow
  bool _paletteComputed = false;

  // palette-utils wants Set<int> of rgbKey for distinctness
  final Set<int> _used = <int>{};

  String get _imagePath =>
      (widget.imageUrl == null || widget.imageUrl!.trim().isEmpty)
      ? 'assets/images/default-images/default-classes.jpg'
      : widget.imageUrl!.trim();

  @override
  void initState() {
    super.initState();
    _computeSideColor();
  }

  @override
  void didUpdateWidget(covariant _SubjectCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _paletteComputed = false;
      _computeSideColor();
    }
  }

  Future<void> _computeSideColor() async {
    if (_paletteComputed) return;

    try {
      // 1) Try fast path: single dominant color
      final dom = await DominantColorUtils.fromPath(_imagePath);
      if (mounted && dom != null) {
        _used.add(PaletteUtils.rgbKey(dom));
        setState(() {
          _sideColor = dom;
          _paletteComputed = true;
        });
        return;
      }

      // 2) Fallback: small palette, then pick a distinct one
      final palette = await PaletteUtils.paletteFromPath(
        _imagePath,
        maxColors: 5,
      );
      if (!mounted) return;

      if (palette.isNotEmpty) {
        final picked =
            PaletteUtils.pickDistinct(palette, _used, minDistance: 40) ??
            palette.first;
        _used.add(PaletteUtils.rgbKey(picked));
        setState(() {
          _sideColor = picked;
          _paletteComputed = true;
        });
      } else {
        setState(() => _paletteComputed = true);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _paletteComputed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final iconColor = Colors.grey.shade500;
    final iconSize = screenWidth * 0.045;
    final textStyle = TextStyle(
      color: Colors.grey.shade500,
      fontSize: screenWidth * 0.032,
    );

    return Card(
      color: Colors.white,
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      elevation: 5,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.02),
          border: Border(
            left: BorderSide(color: _sideColor, width: screenWidth * 0.005),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // image (network or asset)
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(screenWidth * 0.025),
                topRight: Radius.circular(screenWidth * 0.025),
              ),
              child: _buildHeaderImage(
                context,
                path: _imagePath,
                height: screenHeight * 0.15,
                onReady: _computeSideColor, // compute again once loaded
              ),
            ),

            // text content
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.025,
                vertical: screenHeight * 0.015,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.classCode,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.045,
                    ),
                  ),
                  Text(
                    widget.subject,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Wrap(
                    spacing: screenWidth * 0.05,
                    runSpacing: screenHeight * 0.008,
                    children: [
                      _infoItem(
                        icon: Icons.calendar_month,
                        text: widget.time.isNotEmpty
                            ? widget.time
                            : "Schedule TBA",
                        iconColor: iconColor,
                        iconSize: iconSize,
                        textStyle: textStyle,
                        maxTextWidth: screenWidth * 0.70,
                      ),
                      _infoItem(
                        icon: Icons.person,
                        text: widget.teacherName.isNotEmpty
                            ? widget.teacherName
                            : 'TBA',
                        iconColor: iconColor,
                        iconSize: iconSize,
                        textStyle: textStyle,
                        maxTextWidth: screenWidth * 0.70,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- helpers ---

  Widget _infoItem({
    required IconData icon,
    required String text,
    required Color iconColor,
    required double iconSize,
    required TextStyle textStyle,
    required double maxTextWidth,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: iconSize),
        const SizedBox(width: 6),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxTextWidth),
          child: Text(
            text,
            style: textStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            softWrap: false,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderImage(
    BuildContext context, {
    required String path,
    required double height,
    required VoidCallback onReady,
  }) {
    // quick path test
    final isNet = path.startsWith('http://') || path.startsWith('https://');

    if (!isNet) {
      // asset
      WidgetsBinding.instance.addPostFrameCallback((_) => onReady());
      return Image.asset(
        path,
        fit: BoxFit.cover,
        height: height,
        width: double.infinity,
      );
    }

    // network
    return Image.network(
      path,
      fit: BoxFit.cover,
      height: height,
      width: double.infinity,
      errorBuilder: (_, __, ___) {
        WidgetsBinding.instance.addPostFrameCallback((_) => onReady());
        return Image.asset(
          'assets/images/default-images/default-classes.jpg',
          fit: BoxFit.cover,
          height: height,
          width: double.infinity,
        );
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) => onReady());
          return child;
        }
        return _skeletonBanner(height);
      },
      gaplessPlayback: true,
      filterQuality: FilterQuality.low,
    );
  }

  Widget _skeletonBanner(double height) {
    return Container(
      height: height,
      width: double.infinity,
      color: Colors.white,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF234EF4)),
      ),
    );
  }
}
