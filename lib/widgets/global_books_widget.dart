import 'package:flutter/material.dart';
import 'package:flutter_lms/widgets/base_widgets.dart';
import 'package:flutter_lms/utils/dominant_color_utils.dart';
import 'package:flutter_lms/utils/palette_utils.dart';
import 'package:flutter_lms/config/constants.dart'; // <-- add this

class GlobalBooksWidget extends BaseWidget {
  final String subject;
  final String grade_level;
  final String totalSections;
  final String dateAssined;
  final String? imageUrl;

  const GlobalBooksWidget({
    super.key,
    required this.grade_level, required this.totalSections, required this.dateAssined, required this.subject, required this.imageUrl, required
  });

  @override
  Widget build(BuildContext context) {
    return _SubjectCard(
      subject: subject,
      grade_level: grade_level,
      dateAssined: dateAssined,
      imageUrl: imageUrl, totalSections: totalSections,
    );
  }
}

class _SubjectCard extends StatefulWidget {
  final String subject;
  final String grade_level;
  final String totalSections;
  final String dateAssined;
  final String? imageUrl;

  const _SubjectCard({
    required this.grade_level, required this.totalSections, required this.dateAssined, required this.subject, required this.imageUrl,
  });

  @override
  State<_SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<_SubjectCard> {
  static const String _kDefaultAsset =
      'assets/images/default-images/default-classes.jpg';

  String get _imageBaseUrl => AppConstants.imageBaseUrl;

  Color _sideColor = const Color(0xFFFFD400);
  bool _paletteComputed = false;
  final Set<int> _used = <int>{};

  String? get _networkUrl {
    final raw = widget.imageUrl?.trim();
    if (raw == null || raw.isEmpty) return null;

    final lower = raw.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return raw;
    }

    if (!lower.startsWith('assets/')) {
      final hasTrailingSlash = _imageBaseUrl.endsWith('/');
      final hasLeadingSlash = raw.startsWith('/');
      final joined = hasTrailingSlash && hasLeadingSlash
          ? '$_imageBaseUrl${raw.substring(1)}'
          : (!hasTrailingSlash && !hasLeadingSlash
                ? '$_imageBaseUrl/$raw'
                : '$_imageBaseUrl$raw');
      return joined;
    }
    return null;
  }

  String get _colorSourcePath => _networkUrl ?? _kDefaultAsset;

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
      final dom = await DominantColorUtils.fromPath(_colorSourcePath);
      if (mounted && dom != null) {
        _used.add(PaletteUtils.rgbKey(dom));
        setState(() {
          _sideColor = dom;
          _paletteComputed = true;
        });
        return;
      }

      final palette = await PaletteUtils.paletteFromPath(
        _colorSourcePath,
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
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(screenWidth * 0.025),
                topRight: Radius.circular(screenWidth * 0.025),
              ),
              child: _buildHeaderImage(
                context,
                networkUrl: _networkUrl,
                assetFallback: _kDefaultAsset,
                height: screenHeight * 0.15,
                onReady: _computeSideColor,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.025,
                vertical: screenHeight * 0.015,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.subject,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.045,
                    ),
                  ),
                  Text(
                    widget.grade_level,
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
                        icon: Icons.person,
                        text: widget.totalSections.isNotEmpty
                            ? widget.totalSections
                            : "Schedule TBA",
                        iconColor: iconColor,
                        iconSize: iconSize,
                        textStyle: textStyle,
                        maxTextWidth: screenWidth * 0.70,
                      ),
                      _infoItem(
                        icon: Icons.calendar_month,
                        text: widget.dateAssined.isNotEmpty
                            ? widget.dateAssined
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
    required String? networkUrl,
    required String assetFallback,
    required double height,
    required VoidCallback onReady,
  }) {
    // No network URL (null/empty or an asset path) -> use asset fallback
    if (networkUrl == null || networkUrl.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => onReady());
      return Image.asset(
        assetFallback,
        fit: BoxFit.cover,
        height: height,
        width: double.infinity,
      );
    }

    return Image.network(
      networkUrl,
      fit: BoxFit.cover,
      height: height,
      width: double.infinity,
      errorBuilder: (_, __, ___) {
        WidgetsBinding.instance.addPostFrameCallback((_) => onReady());
        return Image.asset(
          assetFallback,
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
