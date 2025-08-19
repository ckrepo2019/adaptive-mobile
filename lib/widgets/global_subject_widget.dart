import 'package:flutter_lms/widgets/base_widgets.dart';
import 'package:flutter/material.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final iconColor = Colors.grey.shade500;
    final iconSize = screenWidth * 0.045;
    final textStyle = TextStyle(
      color: Colors.grey.shade500,
      fontSize: screenWidth * 0.032,
    );

    return Card(
      color: Colors.white, // ✅ full white background
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      elevation: 5,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // ✅ enforce white inside too
          borderRadius: BorderRadius.circular(screenWidth * 0.02),
          border: Border(
            left: BorderSide(color: Colors.yellow, width: screenWidth * 0.005),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Top Image with fallback =====
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(screenWidth * 0.025),
                topRight: Radius.circular(screenWidth * 0.025),
              ),
              child: _buildHeaderImage(
                context,
                imageUrl: imageUrl,
                height: screenHeight * 0.15,
              ),
            ),

            // ===== Text Section =====
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.025,
                vertical: screenHeight * 0.015,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Class code
                  Text(
                    classCode,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.045,
                    ),
                  ),

                  // Subject name
                  Text(
                    subject,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: screenWidth * 0.04,
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // ===== Bottom (time & teacher) — wraps if needed =====
                  Wrap(
                    spacing: screenWidth * 0.05,
                    runSpacing: screenHeight * 0.008,
                    children: [
                      _infoItem(
                        icon: Icons.calendar_month,
                        text: time.isNotEmpty ? time : "Schedule TBA",
                        iconColor: iconColor,
                        iconSize: iconSize,
                        textStyle: textStyle,
                        maxTextWidth: screenWidth * 0.70,
                      ),
                      _infoItem(
                        icon: Icons.person,
                        text: teacherName.isNotEmpty ? teacherName : 'TBA',
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

  // ---- helpers ----

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
    required String? imageUrl,
    required double height,
  }) {
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return _fallbackBanner(height);
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      height: height,
      width: double.infinity,
      errorBuilder: (_, __, ___) => _fallbackBanner(height),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _skeletonBanner(height);
      },
    );
  }

  Widget _fallbackBanner(double height) {
    return Image.asset(
      'assets/images/default-images/default-classes.jpg',
      fit: BoxFit.cover,
      height: height,
      width: double.infinity,
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
