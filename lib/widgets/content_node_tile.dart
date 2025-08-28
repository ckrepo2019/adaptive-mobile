// lib/widgets/content_node_tile.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_lms/models/node.dart';
import 'package:flutter_lms/widgets/gradient_cta_button.dart';

class ContentNodeTile extends StatefulWidget {
  final Node node;
  final String? ctaText;
  final VoidCallback? onCtaPressed;
  final Widget? leading;

  const ContentNodeTile({
    super.key,
    required this.node,
    this.ctaText,
    this.onCtaPressed,
    this.leading,
  });

  @override
  State<ContentNodeTile> createState() => _ContentNodeTileState();
}

class _ContentNodeTileState extends State<ContentNodeTile>
    with TickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final node = widget.node;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            onExpansionChanged: (e) => setState(() => _expanded = e),
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
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
                    Icons.menu_book_outlined,
                    color: Colors.white,
                  ),
                ),
            title: Text(
              node.name,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              softWrap: true,
            ),
            subtitle: node.description.trim().isEmpty
                ? null
                : Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeInOut,
                      alignment: Alignment.topLeft,
                      child: Text(
                        node.description,
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
              if (node.children.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Text(
                    'No items',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                )
              else
                ...node.children.map(
                  (c) => ContentNodeTile(
                    node: c,
                    ctaText: widget.ctaText,
                    onCtaPressed: widget.onCtaPressed,
                    leading: widget.leading,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
