import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_lms/models/node.dart';
import 'package:flutter_lms/widgets/assessment_buttons.dart';

typedef NodeLeadingBuilder = Widget Function(BuildContext context, Node node);
typedef NodeTitleBuilder = Widget Function(BuildContext context, Node node);
typedef NodeSubtitleBuilder = Widget Function(BuildContext context, Node node);
typedef NodeIsAssessment = bool Function(Node node);
typedef NodeActionsBuilder =
    List<Widget> Function(BuildContext context, Node node);

class NodeTree extends StatelessWidget {
  final List<Node> nodes;
  final NodeLeadingBuilder? leadingBuilder;
  final NodeTitleBuilder? titleBuilder;
  final NodeSubtitleBuilder? subtitleBuilder;
  final NodeActionsBuilder? actionsBuilder;
  final void Function(Node node)? onTapLeaf;
  final NodeIsAssessment? isAssessment;

  const NodeTree({
    super.key,
    required this.nodes,
    this.leadingBuilder,
    this.titleBuilder,
    this.subtitleBuilder,
    this.actionsBuilder,
    this.onTapLeaf,
    this.isAssessment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: nodes
          .map((n) => _NodeView(node: n, tree: this))
          .toList(growable: false),
    );
  }
}

class _NodeView extends StatelessWidget {
  final Node node;
  final NodeTree tree;
  const _NodeView({required this.node, required this.tree});

  bool _isAssessment(Node n) {
    if (tree.isAssessment != null) return tree.isAssessment!(n);
    final name = (n.name).toLowerCase();
    final desc = (n.description).toLowerCase();
    bool hasKeyword(String s) =>
        s.contains('assessment') ||
        s.contains('quiz') ||
        s.contains('exam') ||
        s.contains('test');
    return hasKeyword(name) || hasKeyword(desc);
  }

  @override
  Widget build(BuildContext context) {
    if (_isAssessment(node)) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        child: Material(
          color: const Color(0xFFFDFDFE),
          borderRadius: BorderRadius.circular(12),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading:
                  tree.leadingBuilder?.call(context, node) ??
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.quiz_outlined, color: Colors.white),
                  ),
              title:
                  tree.titleBuilder?.call(context, node) ??
                  Text(
                    node.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
              subtitle: (tree.subtitleBuilder != null)
                  ? tree.subtitleBuilder!(context, node)
                  : (node.description.trim().isEmpty
                        ? null
                        : Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              node.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 12.5,
                                color: Colors.black54,
                              ),
                            ),
                          )),
              trailing: const Icon(
                Icons.expand_more_rounded,
                color: Colors.black45,
              ),
              children: [
                const SizedBox(height: 4),
                ...(tree.actionsBuilder?.call(context, node) ??
                    [const AssessmentButtons()]),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      );
    }
    return _ContentNodeTile(node: node, tree: tree);
  }
}

class _ContentNodeTile extends StatefulWidget {
  final Node node;
  final NodeTree tree;
  const _ContentNodeTile({required this.node, required this.tree});

  @override
  State<_ContentNodeTile> createState() => _ContentNodeTileState();
}

class _ContentNodeTileState extends State<_ContentNodeTile>
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
                widget.tree.leadingBuilder?.call(context, node) ??
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
            title:
                widget.tree.titleBuilder?.call(context, node) ??
                Text(
                  node.name,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  softWrap: true,
                ),
            subtitle: (widget.tree.subtitleBuilder != null)
                ? widget.tree.subtitleBuilder!(context, node)
                : (node.description.trim().isEmpty
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
                        )),
            trailing: const Icon(
              Icons.expand_more_rounded,
              color: Colors.black45,
            ),
            children: [
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
                  (child) => _NodeView(node: child, tree: widget.tree),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
