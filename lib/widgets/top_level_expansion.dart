// lib/widgets/top_level_expansion.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_lms/widgets/gradient_cta_button.dart';

class TopLevelExpansion extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? ctaText;
  final VoidCallback? onCtaPressed;
  final bool initiallyExpanded;
  final Widget child;
  final Widget? leading;

  const TopLevelExpansion({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.ctaText,
    this.onCtaPressed,
    this.initiallyExpanded = false,
    this.leading,
  });

  @override
  State<TopLevelExpansion> createState() => _TopLevelExpansionState();
}

class _TopLevelExpansionState extends State<TopLevelExpansion>
    with TickerProviderStateMixin {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: widget.initiallyExpanded,
          onExpansionChanged: (e) => setState(() => _expanded = e),
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          leading:
              widget.leading ??
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF4F6BFF),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.description_outlined,
                  color: Colors.white,
                ),
              ),
          title: Text(
            widget.title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            softWrap: true,
          ),
          subtitle: widget.subtitle.trim().isEmpty
              ? null
              : Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topLeft,
                    child: Text(
                      widget.subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.black54,
                      ),
                      softWrap: true,
                      maxLines: _expanded ? null : 2,
                      overflow: _expanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                    ),
                  ),
                ),
          trailing: const Icon(
            Icons.expand_more_rounded,
            color: Colors.black45,
          ),
          children: [
            if (_expanded && widget.ctaText != null)
              GradientCtaButton(
                label: widget.ctaText!,
                onPressed: widget.onCtaPressed,
              ),
            widget.child,
          ],
        ),
      ),
    );
  }
}
