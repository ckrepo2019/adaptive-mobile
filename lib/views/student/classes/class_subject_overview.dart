import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:Adaptive/config/routes.dart';
import 'package:Adaptive/controllers/api_response.dart';
import 'package:Adaptive/controllers/student/student_subject.dart';
import 'package:Adaptive/widgets/app_bar.dart';
import 'package:google_fonts/google_fonts.dart';

Future<T> retry<T>(
  Future<T> Function() fn, {
  int retries = 3,
  Duration delay = const Duration(seconds: 1),
  bool Function(T result)? shouldRetry,
}) async {
  T result = await fn();
  int attempt = 0;
  while (attempt < retries && shouldRetry != null && shouldRetry(result)) {
    await Future.delayed(delay);
    result = await fn();
    attempt++;
  }
  return result;
}

int? _asIntStatic(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

class Node {
  final String type;
  final String name;
  final String description;
  final int? sort;
  final List<Node> children;
  final int? bookId;
  final int? subjectId;
  final int? hierarchyId;
  final int? bookcontentId;
  final String? hierarchyName;
  final int? assessmentOrder;

  Node({
    required this.type,
    required this.name,
    required this.description,
    required this.children,
    this.sort,
    this.bookId,
    this.subjectId,
    this.hierarchyId,
    this.bookcontentId,
    this.hierarchyName,
    this.assessmentOrder,
  });

  Node copyWith({List<Node>? children, int? assessmentOrder}) {
    return Node(
      type: type,
      name: name,
      description: description,
      sort: sort,
      children: children ?? this.children,
      bookId: bookId,
      subjectId: subjectId,
      hierarchyId: hierarchyId,
      bookcontentId: bookcontentId,
      hierarchyName: hierarchyName,
      assessmentOrder: assessmentOrder ?? this.assessmentOrder,
    );
  }
}

class ParentState {
  bool loading;
  String? error;
  List<Node>? children;

  ParentState({this.loading = false, this.error, this.children});
}

class ClassSubjectOverviewPage extends StatefulWidget {
  const ClassSubjectOverviewPage({super.key});

  @override
  State<ClassSubjectOverviewPage> createState() =>
      _ClassSubjectOverviewPageState();
}

class _ClassSubjectOverviewPageState extends State<ClassSubjectOverviewPage> {
  int? _subjectId;
  String? _subjectName;
  String? _subjectCode;
  bool _didArgs = false;
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _parents = const [];
  final Map<int, ParentState> _parentStates = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didArgs) return;
    _didArgs = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      final rawId =
          args['subject_ID'] ?? args['subjectId'] ?? args['subjectID'];
      _subjectId = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');
      _subjectName = (args['subject_name'] ?? '').toString().trim();
      _subjectCode = (args['subject_code'] ?? 'Unknown Code').toString();
    }
    _loadParents();
  }

  Future<void> _loadParents() async {
    if (_subjectId == null || _subjectId! <= 0) {
      setState(() {
        _loading = false;
        _error = 'No subject ID provided';
        _parents = const [];
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _parents = const [];
      _parentStates.clear();
    });
    final resp = await retry(
      () => StudentSubjectController.fetchAllFirstLevelContents(
        subjectId: _subjectId!,
      ),
      retries: 3,
      delay: const Duration(seconds: 1),
      shouldRetry: (ApiResponse resp) =>
          !resp.success && (resp.message?.contains('Invalid JSON') ?? false),
    );
    if (!mounted) return;
    if (!resp.success || resp.data == null) {
      setState(() {
        _loading = false;
        _error = resp.message ?? 'Failed to load first-level contents';
        _parents = const [];
      });
      return;
    }
    setState(() {
      _parents = resp.data!;
      _loading = false;
    });
  }

  int? _asInt(dynamic v) => _asIntStatic(v);

  Future<void> _loadChildrenAndPrint({
    required int parentId,
    required int bookId,
  }) async {
    final state = _parentStates[parentId] ?? ParentState();
    if (state.loading) return;
    if (state.children != null) return;
    setState(() {
      _parentStates[parentId] = ParentState(loading: true);
    });
    try {
      final resp = await retry(
        () => StudentSubjectController.fetchBookUnitContentRaw(
          bookId: bookId,
          parentId: parentId,
          subjectId: _subjectId!,
        ),
        retries: 3,
        delay: const Duration(seconds: 1),
        shouldRetry: (ApiResponse resp) =>
            !resp.success && (resp.message?.contains('Invalid JSON') ?? false),
      );
      if (!resp.success || resp.data == null || resp.data!.trim().isEmpty) {
        setState(() {
          _parentStates[parentId] = ParentState(
            loading: false,
            error: resp.message ?? 'No items',
          );
        });
        return;
      }
      final children = _parseRootChildren(resp.data!);
      final numbered = _numberAssessments(children);
      setState(() {
        _parentStates[parentId] = ParentState(
          loading: false,
          children: numbered,
        );
      });
    } catch (e) {
      setState(() {
        _parentStates[parentId] = ParentState(
          loading: false,
          error: 'Error: $e',
        );
      });
    }
  }

  List<Node> _numberAssessments(List<Node> roots) {
    int counter = 0;
    Node assign(Node n) {
      if (n.type == 'assessment') {
        counter += 1;
        return n.copyWith(assessmentOrder: counter);
      }
      if (n.children.isEmpty) return n;
      final newKids = n.children.map(assign).toList(growable: false);
      return n.copyWith(children: newKids);
    }

    return roots.map(assign).toList(growable: false);
  }

  List<Node> _parseRootChildren(String jsonText) {
    dynamic decoded;
    try {
      decoded = jsonDecode(jsonText);
    } catch (_) {
      return const [];
    }

    Node? _buildNodeFromContent(Map contentMap, List<dynamic> childRaw) {
      final name = (contentMap['name'] ?? 'Untitled').toString();
      final desc = (contentMap['description'] ?? '').toString();
      final sort = _asIntStatic(contentMap['sort']);
      final bookId = _asIntStatic(contentMap['bookID'] ?? contentMap['bookId']);
      final subjectId = _asIntStatic(
        contentMap['subjectID'] ?? contentMap['subjectId'],
      );
      final hierarchyId = _asIntStatic(
        contentMap['hierarchyID'] ?? contentMap['hierarchyId'],
      );
      final bookcontentId = _asIntStatic(
        contentMap['bookcontentID'] ??
            contentMap['bookContentID'] ??
            contentMap['bookContentId'],
      );
      final hierarchyNameRaw = (contentMap['hierarchy_name'] ?? '').toString();
      final hierarchyName = hierarchyNameRaw.trim().isEmpty
          ? null
          : hierarchyNameRaw;
      final children = _parseNodesRecursively(childRaw);
      _sortNodes(children);
      return Node(
        type: 'content',
        name: name,
        description: desc,
        sort: sort,
        children: children,
        bookId: bookId,
        subjectId: subjectId,
        hierarchyId: hierarchyId,
        bookcontentId: bookcontentId,
        hierarchyName: hierarchyName,
      );
    }

    List<Node> parseOneRoot(dynamic root) {
      if (root is! Map) return const [];
      final String type = (root['type'] ?? '').toString();
      if (type == 'content') {
        final List rawChildren = root['children'] is List
            ? root['children'] as List
            : const [];
        final content = root['content'];
        final List contentChildren =
            (content is Map && content['children'] is List)
            ? content['children'] as List
            : const [];
        final List merged = rawChildren.isNotEmpty
            ? rawChildren
            : contentChildren;
        if (content is! Map) return const [];
        final node = _buildNodeFromContent(content, merged);
        return node == null ? const [] : [node];
      }
      if (type == 'assessment') {
        final content = root['content'];
        if (content is! Map) return const [];
        final name = (content['assessment_name'] ?? 'Assessment').toString();
        final desc = (content['assessment_description'] ?? '').toString();
        final sort = _asInt(content['sort']);
        return [
          Node(
            type: 'assessment',
            name: name,
            description: desc,
            sort: sort,
            children: const [],
            hierarchyName: 'Assessment',
          ),
        ];
      }
      return const [];
    }

    if (decoded is List) {
      final out = <Node>[];
      for (final root in decoded) {
        out.addAll(parseOneRoot(root));
      }
      _sortNodes(out);
      return out;
    }
    if (decoded is Map) {
      return parseOneRoot(decoded);
    }
    return const [];
  }

  List<Node> _parseNodesRecursively(List<dynamic> rawList) {
    final out = <Node>[];
    for (final item in rawList) {
      if (item is! Map) continue;
      final String type = (item['type'] ?? '').toString();
      if (type == 'content') {
        final content = item['content'];
        if (content is! Map) continue;
        final name = (content['name'] ?? 'Untitled').toString();
        final desc = (content['description'] ?? '').toString();
        final sort = _asInt(content['sort']);
        final bookId = _asIntStatic(content['bookID'] ?? content['bookId']);
        final subjectId = _asIntStatic(
          content['subjectID'] ?? content['subjectId'],
        );
        final hierarchyId = _asIntStatic(
          content['hierarchyID'] ?? content['hierarchyId'],
        );
        final bookcontentId = _asIntStatic(
          content['bookcontentID'] ??
              content['bookContentID'] ??
              content['bookContentId'],
        );
        final hierarchyName =
            (content['hierarchy_name'] ?? '').toString().trim().isEmpty
            ? null
            : content['hierarchy_name'].toString();
        final childRaw = (item['children'] is List)
            ? item['children'] as List
            : const [];
        final children = _parseNodesRecursively(childRaw);
        _sortNodes(children);
        out.add(
          Node(
            type: 'content',
            name: name,
            description: desc,
            sort: sort,
            children: children,
            bookId: bookId,
            subjectId: subjectId,
            hierarchyId: hierarchyId,
            bookcontentId: bookcontentId,
            hierarchyName: hierarchyName,
          ),
        );
      } else if (type == 'assessment') {
        final content = item['content'];
        if (content is! Map) continue;
        final name = (content['assessment_name'] ?? 'Assessment').toString();
        final desc = (content['assessment_description'] ?? '').toString();
        final sort = _asInt(content['sort']);
        out.add(
          Node(
            type: 'assessment',
            name: name,
            description: desc,
            sort: sort,
            children: const [],
            hierarchyName: 'Assessment',
          ),
        );
      }
    }
    return out;
  }

  void _sortNodes(List<Node> nodes) {
    nodes.sort((a, b) {
      final sa = a.sort ?? 1 << 30;
      final sb = b.sort ?? 1 << 30;
      if (sa != sb) return sa.compareTo(sb);
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalAppBar(
        title: _subjectCode ?? 'Unit Overview',
        showBack: true,
      ),
      backgroundColor: Colors.white,
      body: _loading
          ? _buildBlockingLoader()
          : RefreshIndicator(
              onRefresh: _loadParents,
              child: _error != null
                  ? _buildError()
                  : _parents.isEmpty
                  ? _buildEmpty()
                  : _buildList(),
            ),
    );
  }

  Widget _buildBlockingLoader() {
    return const Center(
      child: SizedBox(
        height: 52,
        width: 52,
        child: CircularProgressIndicator(strokeWidth: 4),
      ),
    );
  }

  Widget _buildError() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Center(
          child: Text(_error!, style: GoogleFonts.poppins(fontSize: 14.5)),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Center(
          child: Text(
            'No contents available',
            style: GoogleFonts.poppins(fontSize: 14.5),
          ),
        ),
      ],
    );
  }

  Widget _buildList() {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _parents.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, i) {
        final p = _parents[i];
        final rawName = (p['name'] ?? p['Name'] ?? 'Untitled').toString();
        final hierarchyNameRaw =
            (p['hierarchy_name'] ?? p['HierarchyName'] ?? '').toString();
        final safeHierarchy = hierarchyNameRaw.trim().isEmpty
            ? 'Item'
            : hierarchyNameRaw;
        final displayTitle = '$safeHierarchy ${i + 1}';
        final displaySubtitle = rawName;
        final parentId = _asInt(
          p['bookcontentID'] ?? p['ParentID'] ?? p['parentId'],
        );
        final bookId = _asInt(p['bookID'] ?? p['BookID'] ?? p['bookId']);
        final subjectId =
            _asInt(p['subjectID'] ?? p['SubjectID'] ?? p['subjectId']) ??
            _subjectId;
        final hierarchyId = _asInt(
          p['hierarchyID'] ?? p['HierarchyID'] ?? p['hierarchyId'],
        );
        return _TopLevelExpansionCard(
          title: displayTitle,
          subtitle: displaySubtitle,
          hierarchyName: safeHierarchy,
          onExpanded: (expanded) {
            if (expanded && parentId != null && bookId != null) {
              _loadChildrenAndPrint(parentId: parentId, bookId: bookId);
            }
          },
          onTakePressed: () {
            if (bookId == null || subjectId == null || parentId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Missing identifiers to open content'),
                ),
              );
              return;
            }
            Navigator.pushNamed(
              context,
              AppRoutes.classSubjectBookContent,
              arguments: {
                'bookID': bookId,
                'subjectID': subjectId,
                'hierarchyID': hierarchyId,
                'bookcontentID': parentId,
                'subjectName': _subjectName,
                'subjectCode': _subjectCode,
              },
            );
          },
          child: parentId == null
              ? _noItems()
              : _ParentBody(
                  subjectCode: _subjectCode,
                  state: _parentStates[parentId],
                ),
        );
      },
    );
  }

  Widget _noItems() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
    child: Text(
      'No items',
      style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
    ),
  );
}

class _ParentBody extends StatelessWidget {
  final String? subjectCode;
  final ParentState? state;
  const _ParentBody({this.subjectCode, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state == null) {
      return _noItems();
    }
    if (state!.loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (state!.error != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Text(
          state!.error!,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.redAccent,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }
    final children = state!.children ?? const <Node>[];
    if (children.isEmpty) {
      return _noItems();
    }
    return _NodeList(subjectCode: subjectCode, children: children);
  }

  Widget _noItems() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
    child: Text(
      'No items',
      style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
    ),
  );
}

class _NodeList extends StatelessWidget {
  final String? subjectCode;
  final List<Node> children;
  const _NodeList({this.subjectCode, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        children.length,
        (index) => _NodeView(
          subjectCode: subjectCode,
          node: children[index],
          index: index,
        ),
        growable: false,
      ),
    );
  }
}

class _NodeView extends StatelessWidget {
  final String? subjectCode;
  final Node node;
  final int index;
  const _NodeView({this.subjectCode, required this.node, required this.index});

  @override
  Widget build(BuildContext context) {
    if (node.type == 'assessment') {
      final typeLabel = (node.hierarchyName ?? 'Assessment').toUpperCase();
      final ord = node.assessmentOrder ?? (index + 1);
      final displayTitle = '$typeLabel $ord';
      final displaySubtitle = node.name;

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
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.quiz_outlined, color: Colors.white),
              ),
              title: Text(
                displayTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              subtitle: displaySubtitle.trim().isEmpty
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        displaySubtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ),
              trailing: const Icon(
                Icons.expand_more_rounded,
                color: Colors.black45,
              ),
              children: const [
                SizedBox(height: 4),
                _AssessmentButtons(),
                SizedBox(height: 12),
              ],
            ),
          ),
        ),
      );
    }
    return _ContentNodeTile(subjectCode: subjectCode, node: node, index: index);
  }
}

class _AssessmentButtons extends StatelessWidget {
  final VoidCallback? onShowResult;
  final VoidCallback? onLevelUp;

  const _AssessmentButtons({this.onLevelUp, this.onShowResult});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF6A5AE0)),
                foregroundColor: const Color(0xFF6A5AE0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: onShowResult,
              child: Text(
                "Show Result",
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.green,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6A5AE0), Color(0xFF4F6BFF)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: onLevelUp,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Level Up Knowledge",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentNodeTile extends StatefulWidget {
  final String? subjectCode;
  final Node node;
  final int index;
  const _ContentNodeTile({
    this.subjectCode,
    required this.node,
    required this.index,
  });

  @override
  State<_ContentNodeTile> createState() => _ContentNodeTileState();
}

class _ContentNodeTileState extends State<_ContentNodeTile>
    with TickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final node = widget.node;
    final safeHierarchy = (node.hierarchyName ?? '').trim().isEmpty
        ? 'Item'
        : node.hierarchyName!;
    final displayTitle = '$safeHierarchy ${widget.index + 1}';
    final displaySubtitle = node.name;
    final takeLabel =
        'TAKE ${node.hierarchyName?.trim().isEmpty ?? true ? "Item" : node.hierarchyName}';

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
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF4F6BFF),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.menu_book_outlined, color: Colors.white),
            ),
            title: Text(
              displayTitle,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
              softWrap: true,
            ),
            subtitle: displaySubtitle.trim().isEmpty
                ? null
                : Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeInOut,
                      alignment: Alignment.topLeft,
                      child: Text(
                        displaySubtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
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
              if (_expanded)
                _TakeGradientButton(
                  label: takeLabel,
                  onPressed: () {
                    final n = widget.node;
                    if (n.bookId == null ||
                        n.subjectId == null ||
                        n.hierarchyId == null ||
                        n.bookcontentId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Missing identifiers to open content'),
                        ),
                      );
                      return;
                    }
                    Navigator.pushNamed(
                      context,
                      '/book-content',
                      arguments: {
                        'bookID': n.bookId,
                        'subjectID': n.subjectId,
                        'hierarchyID': n.hierarchyId,
                        'bookcontentID': n.bookcontentId,
                        'subjectCode': widget.subjectCode,
                      },
                    );
                  },
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
                ...List.generate(
                  node.children.length,
                  (i) => _NodeView(node: node.children[i], index: i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopLevelExpansionCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? hierarchyName;
  final bool initiallyExpanded;
  final Widget child;
  final void Function(bool expanded)? onExpanded;
  final VoidCallback? onTakePressed;

  const _TopLevelExpansionCard({
    required this.title,
    required this.subtitle,
    required this.child,
    this.hierarchyName,
    this.onExpanded,
    this.onTakePressed,
    this.initiallyExpanded = false,
  });

  @override
  State<_TopLevelExpansionCard> createState() => _TopLevelExpansionCardState();
}

class _TopLevelExpansionCardState extends State<_TopLevelExpansionCard>
    with TickerProviderStateMixin {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final takeLabel =
        'TAKE ${widget.hierarchyName?.trim().isEmpty ?? true ? "Item" : widget.hierarchyName}';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: widget.initiallyExpanded,
          onExpansionChanged: (e) {
            setState(() => _expanded = e);
            widget.onExpanded?.call(e);
          },
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF4F6BFF),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.description_outlined, color: Colors.white),
          ),
          title: Text(
            widget.title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w800,
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
                        fontWeight: FontWeight.w600,
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
            if (_expanded)
              _TakeGradientButton(
                label: takeLabel,
                onPressed: widget.onTakePressed,
              ),
            widget.child,
          ],
        ),
      ),
    );
  }
}

class _TakeGradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _TakeGradientButton({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6A5AE0), Color(0xFF4F6BFF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: SizedBox(
          height: 44,
          width: double.infinity,
          child: TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: onPressed,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
