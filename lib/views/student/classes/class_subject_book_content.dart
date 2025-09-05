import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_lms/config/routes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_lms/widgets/app_bar.dart';
import 'dart:typed_data';

import 'package:flutter_lms/controllers/student/student_subject.dart';
import 'package:flutter_lms/controllers/api_response.dart';
import 'package:flutter_lms/utils/retry.dart';
import 'package:flutter_lms/utils/casting.dart';
import 'package:flutter_lms/parsers/node_parsers.dart';
import 'package:flutter_lms/models/node.dart';

import 'package:flutter_html/flutter_html.dart';

import 'package:pdfx/pdfx.dart';

import 'package:flutter_lms/config/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PanelController extends ChangeNotifier {
  bool expanded = false;

  final List<int> path = [];

  Node? selectedNode;

  String selectedLabel = 'Overview';

  final ValueNotifier<int> contentTick = ValueNotifier<int>(0);
  void _bumpContent() => contentTick.value = contentTick.value + 1;

  void setExpanded(bool v) {
    if (expanded == v) return;
    expanded = v;
    notifyListeners();
  }

  void openRoot() {
    expanded = true;
    notifyListeners();
  }

  void upOneLevel() {
    if (path.isNotEmpty) {
      path.removeLast();
      notifyListeners();
    }
  }

  void pushContentIndex(int idx) {
    path.add(idx);
    notifyListeners();
  }

  void selectNode(Node n) {
    selectedNode = n;
    selectedLabel = n.name;
    expanded = false;
    _bumpContent();
    notifyListeners();
  }

  void selectOverview(Node currentNode) {
    selectedNode = currentNode;
    selectedLabel = '${currentNode.name ?? 'Overview'} Overview';
    expanded = false;
    _bumpContent();
    notifyListeners();
  }

  void resetToRoot() {
    path.clear();
    selectedNode = null;
    selectedLabel = 'Overview';
    expanded = false;
    _bumpContent();
    notifyListeners();
  }
}

class SubjectBookContent extends StatefulWidget {
  const SubjectBookContent({super.key});

  @override
  State<SubjectBookContent> createState() => _SubjectBookContentState();
}

class _SubjectBookContentState extends State<SubjectBookContent>
    with TickerProviderStateMixin {
  String? _subjectName;
  String? _subjectCode;
  int? _bookId, _subjectId, _bookcontentId;

  bool _loading = true;
  String? _error;

  Node? _root;
  String _hierarchyTitle = 'Unit';

  Map<String, String>? _pdfHeaders;

  late final PanelController _panel = PanelController();

  List<Node> _children(Node? n) => n?.children ?? const <Node>[];
  List<Node> _contentChildren(Node? n) =>
      _children(n).where((c) => c.type == 'content').toList();
  List<Node> _assessmentChildren(Node? n) =>
      _children(n).where((c) => c.type == 'assessment').toList();

  Node? _currentNodeForPanel() {
    Node? node = _root;
    for (final idx in _panel.path) {
      final contents = _contentChildren(node);
      if (idx < 0 || idx >= contents.length) return node;
      node = contents[idx];
    }
    return node;
  }

  int? _assessmentIdFromNode(Node? n) => asInt(n?.content?['id']);

  Node? _outsideDisplayNode() => _panel.selectedNode ?? _root;

  String _niceCase(String? s, {String fallback = 'Unit'}) {
    final raw = (s ?? '').trim();
    if (raw.isEmpty) return fallback;
    final lower = raw.toLowerCase();
    return '${lower[0].toUpperCase()}${lower.substring(1)}';
  }

  @override
  void dispose() {
    _panel.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    _subjectName = (args?['subjectName'] ?? 'Book Content').toString();
    _subjectCode = (args?['subjectCode'] ?? 'Unknown Code').toString();
    _bookId = asInt(args?['bookID']);
    _subjectId = asInt(args?['subjectID']);
    _bookcontentId = asInt(args?['bookcontentID']);
    _preparePdfHeaders();
    _load();
  }

  Future<void> _preparePdfHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (!mounted) return;
    setState(() {
      _pdfHeaders = (token != null && token.isNotEmpty)
          ? {'Authorization': 'Bearer $token'}
          : null;
    });
  }

  Future<void> _load() async {
    if ((_bookId ?? 0) <= 0 ||
        (_subjectId ?? 0) <= 0 ||
        (_bookcontentId ?? 0) <= 0) {
      setState(() {
        _loading = false;
        _error = 'Missing identifiers (bookID/subjectID/bookcontentID).';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _root = null;
    });

    final ApiResponse<String> resp = await retry(
      () => StudentSubjectController.fetchBookTreeByContentRaw(
        bookId: _bookId!,
        subjectId: _subjectId!,
        bookcontentId: _bookcontentId!,
      ),
      retries: 2,
      delay: const Duration(milliseconds: 600),
      shouldRetry: (ApiResponse<String> r) =>
          !r.success && (r.message?.contains('Invalid JSON') ?? false),
    );

    if (!mounted) return;

    if (!resp.success || (resp.data ?? '').trim().isEmpty) {
      setState(() {
        _loading = false;
        _error = resp.message ?? 'Failed to load book content tree.';
      });
      return;
    }

    final Node? root = parseRootWithParent(resp.data!);
    _panel.resetToRoot();

    setState(() {
      _loading = false;
      _root = root;
      _hierarchyTitle = _niceCase(root?.hierarchyName, fallback: 'Unit');
    });
  }

  String? _pdfUrl(String? filePath) {
    if (filePath == null) return null;
    final f = filePath.trim();
    if (f.isEmpty) return null;

    if (f.startsWith('http://') || f.startsWith('https://')) return f;

    final api = Uri.parse(AppConstants.baseURL);
    final origin =
        '${api.scheme}://${api.host}${api.hasPort ? ':${api.port}' : ''}';

    String rel;
    if (f.startsWith('storage/')) {
      rel = f;
    } else if (f.startsWith('/storage/')) {
      rel = f.substring(1);
    } else {
      rel = 'storage/$f';
    }

    return '$origin/$rel';
  }

  @override
  Widget build(BuildContext context) {
    final themeBlue = const Color(0xFF2458FF);
    final panelRadius = const Radius.circular(24);

    final collapsedHeight = 64.0;
    final expandedHeight = MediaQuery.of(context).size.height * 0.45;

    return Scaffold(
      appBar: GlobalAppBar(
        title: _subjectCode ?? 'Book Content',
        showBack: true,
      ),
      backgroundColor: const Color(0xFFF6F6F8),
      body: Stack(
        children: [
          if (_loading)
            const Center(
              child: SizedBox(
                height: 52,
                width: 52,
                child: CircularProgressIndicator(strokeWidth: 4),
              ),
            )
          else
            ValueListenableBuilder<int>(
              valueListenable: _panel.contentTick,
              builder: (context, _, __) {
                final Node? baseNode = _outsideDisplayNode();
                final String titleToShow =
                    (baseNode?.name.trim().isNotEmpty ?? false)
                    ? baseNode!.name
                    : (_root?.name.trim().isNotEmpty == true
                          ? _root!.name
                          : '—');

                final contents = _contentChildren(baseNode);
                final assessments = _assessmentChildren(baseNode);
                final pdfUrl = _pdfUrl(baseNode?.file);

                return RepaintBoundary(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 200),
                    children: [
                      _OverviewCard(
                        title: titleToShow,
                        description: baseNode?.description ?? '',
                        html: baseNode?.html,
                        hierarchyTitle: _hierarchyTitle,
                        isAssessment: (baseNode?.type == 'assessment'),
                        onStartAssessment: () {
                          final id = baseNode?.content?['id'];
                          if (id == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Missing assessment id'),
                              ),
                            );
                            return;
                          }
                          Navigator.of(context).pushNamed(
                            AppRoutes.quizInfo,
                            arguments: {'id': id},
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      if ((pdfUrl ?? '').isNotEmpty) ...[
                        _PdfPagesList(pdfUrl: pdfUrl!, headers: _pdfHeaders),
                        const SizedBox(height: 16),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            ),

          AnimatedBuilder(
            animation: _panel,
            builder: (context, _) {
              final cur = _currentNodeForPanel();
              final curContents = _contentChildren(cur);
              final curAssess = _assessmentChildren(cur);

              final expandedHeaderTitle = (cur?.name.trim().isNotEmpty ?? false)
                  ? cur!.name
                  : (_root?.name.trim().isNotEmpty == true ? _root!.name : '—');

              return Stack(
                children: [
                  if (_panel.expanded)
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _panel.setExpanded(false),
                      ),
                    ),

                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: _panel.expanded ? expandedHeight : collapsedHeight,
                    child: SafeArea(
                      top: false,
                      child: _BottomPanel(
                        color: themeBlue,
                        radius: panelRadius,
                        expanded: _panel.expanded,
                        header: _PanelHeader(
                          title: _panel.expanded
                              ? expandedHeaderTitle
                              : _panel.selectedLabel,
                          leadingIcon: Icons.menu_book_outlined,
                          trailing: _panel.expanded && _panel.path.isNotEmpty
                              ? _Chevron(
                                  down: false,
                                  color: Colors.white,
                                  onTap: _panel.upOneLevel,
                                )
                              : null,
                          onTap: _panel.openRoot,
                        ),
                        collapsedBar: !_panel.expanded
                            ? _CollapsedBar(
                                color: themeBlue,
                                title: _panel.selectedLabel,
                                icon: Icons.menu_book_outlined,
                                onTap: () => _panel.setExpanded(true),
                              )
                            : null,
                        child: _panel.expanded
                            ? Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  const SizedBox(height: 6),
                                  Expanded(
                                    child: _buildDynamicLevelList(
                                      currentNode: cur,
                                      contents: curContents,
                                      assessments: curAssess,
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicLevelList({
    required Node? currentNode,
    required List<Node> contents,
    required List<Node> assessments,
  }) {
    if ((contents.isEmpty) && (assessments.isEmpty)) {
      return Column(
        children: [
          const Expanded(child: _NoContent()),
          if (_panel.path.isNotEmpty)
            _BackLevelButton(
              label:
                  'Back to ${_niceCase(currentNode?.hierarchyName ?? _hierarchyTitle)}',
              onTap: _panel.upOneLevel,
            ),
        ],
      );
    }

    final items = <_LevelItem>[];

    items.add(
      _LevelItem.overview(
        label: '${currentNode?.name ?? _hierarchyTitle} Overview',
        onTap: () {
          if (currentNode != null) _panel.selectOverview(currentNode);
        },
      ),
    );

    for (var i = 0; i < contents.length; i++) {
      final n = contents[i];
      final hasKids = _children(n).isNotEmpty;
      items.add(
        _LevelItem.content(
          label: n.name,
          onTap: hasKids
              ? () => _panel.pushContentIndex(i)
              : () => _panel.selectNode(n),
        ),
      );
    }

    for (final a in assessments) {
      items.add(
        _LevelItem.assessment(label: a.name, onTap: () => _panel.selectNode(a)),
      );
    }

    return Column(
      children: [
        Expanded(child: _LevelList(items: items)),
        if (_panel.path.isNotEmpty)
          _BackLevelButton(
            label:
                'Back to ${_niceCase(currentNode?.hierarchyName ?? _hierarchyTitle)}',
            onTap: _panel.upOneLevel,
          ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final String description;
  final String? html;
  final String hierarchyTitle;

  final bool isAssessment;

  final VoidCallback? onStartAssessment;

  const _OverviewCard({
    required this.title,
    required this.description,
    required this.html,
    required this.hierarchyTitle,
    this.isAssessment = false,
    this.onStartAssessment,
  });

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      Text(
        title,
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 6),
    ];

    if (description.trim().isNotEmpty) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            description,
            style: GoogleFonts.poppins(fontSize: 12.5, color: Colors.black87),
          ),
        ),
      );
    }

    final hasHtml = (html ?? '').isNotEmpty;

    if (hasHtml) {
      children.add(
        Html(
          data: html!,
          style: {
            'body': Style(
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
              fontSize: FontSize(14),
              color: Colors.black87,
              lineHeight: LineHeight.number(1.45),
            ),
          },
        ),
      );
    } else {
      if (isAssessment) {
        children.add(const SizedBox(height: 8));
        children.add(_AssessmentCTA(onPressed: onStartAssessment));
      } else {
        children.add(
          Text(
            '$hierarchyTitle overview has no rich content.',
            style: GoogleFonts.poppins(fontSize: 12.5, color: Colors.black54),
          ),
        );
      }
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class _AssessmentCTA extends StatelessWidget {
  final VoidCallback? onPressed;
  const _AssessmentCTA({this.onPressed});

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFFFA000);
    const textColor = Color(0xFFFFA000);

    return SizedBox(
      width: 220,
      height: 44,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: borderColor, width: 1.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          foregroundColor: textColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Start Assessment',
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 18, color: textColor),
          ],
        ),
      ),
    );
  }
}

class _PdfRenderQueue {
  static Future<void> _tail = Future.value();

  static Future<T> enqueue<T>(Future<T> Function() job) {
    final completer = Completer<T>();
    _tail = _tail.then((_) async {
      try {
        completer.complete(await job());
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });
    // Don’t let errors break the chain
    _tail = _tail.catchError((_) {});
    return completer.future;
  }
}

class _PdfPagesList extends StatefulWidget {
  final String pdfUrl;
  final Map<String, String>? headers;
  const _PdfPagesList({required this.pdfUrl, this.headers});

  @override
  State<_PdfPagesList> createState() => _PdfPagesListState();
}

class _PdfPagesListState extends State<_PdfPagesList> {
  Future<_PdfDocInfo>? _loader;

  @override
  void initState() {
    super.initState();
    _loader = _loadPdf();
  }

  Future<_PdfDocInfo> _loadPdf() async {
    final bytes = await _fetchBytes(widget.pdfUrl, widget.headers);
    final doc = await PdfDocument.openData(bytes);
    return _PdfDocInfo(pageCount: doc.pagesCount, document: doc);
  }

  static Future<List<int>> _readAll(HttpClientResponse res) async {
    final chunks = <int>[];
    await for (final d in res) {
      chunks.addAll(d);
    }
    return chunks;
  }

  static Future<Uint8List> _fetchBytes(
    String url,
    Map<String, String>? headers,
  ) async {
    final u = Uri.parse(url);
    final client = HttpClient();
    final req = await client.getUrl(u);
    headers?.forEach((k, v) => req.headers.set(k, v));
    final res = await req.close();
    if (res.statusCode < 200 || res.statusCode >= 300) {
      final text = await res.transform(const Utf8Decoder()).join();
      client.close();
      throw HttpException('Failed to load PDF: ${res.statusCode} $text');
    }
    final bytes = Uint8List.fromList(await _readAll(res));
    client.close();
    return bytes;
  }

  @override
  void dispose() {
    _loader?.then((info) async {
      try {
        await info.document.close();
      } catch (_) {}
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_PdfDocInfo>(
      future: _loader,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return _PdfLoadingCard();
        }
        if (snap.hasError) {
          return _PdfErrorCard(error: '${snap.error}');
        }

        final info = snap.data!;
        return Column(
          children: List.generate(info.pageCount, (i) {
            final pageNumber = i + 1;
            return _PdfPageCard(
              document: info.document,
              pageNumber: pageNumber,
            );
          }),
        );
      },
    );
  }
}

class _PdfDocInfo {
  final int pageCount;
  final PdfDocument document;
  _PdfDocInfo({required this.pageCount, required this.document});
}

class _PdfLoadingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        alignment: Alignment.center,
        child: const CircularProgressIndicator(strokeWidth: 3),
      ),
    );
  }
}

class _PdfErrorCard extends StatelessWidget {
  final String error;
  const _PdfErrorCard({required this.error});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Unable to display PDF.\n$error',
          style: GoogleFonts.poppins(color: Colors.red[700], fontSize: 12.5),
        ),
      ),
    );
  }
}

class _PdfPageCard extends StatefulWidget {
  final PdfDocument document;
  final int pageNumber;
  const _PdfPageCard({required this.document, required this.pageNumber});

  @override
  State<_PdfPageCard> createState() => _PdfPageCardState();
}

class _PdfPageCardState extends State<_PdfPageCard> {
  late final Future<_RenderedPage> _renderFuture = _render();

  Future<_RenderedPage> _render() {
    return _PdfRenderQueue.enqueue<_RenderedPage>(() async {
      final page = await widget.document.getPage(widget.pageNumber);
      try {
        final double screenWidth = MediaQuery.of(context).size.width - 32.0;

        final double dpr = MediaQuery.of(context).devicePixelRatio;
        final double quality = (dpr * 1.5).clamp(1.5, 2.5);

        final double aspect = page.height / page.width;
        final double targetWidthPx = (screenWidth * quality);
        final double targetHeightPx = (targetWidthPx * aspect);

        final PdfPageImage? img = await page.render(
          width: targetWidthPx,
          height: targetHeightPx,
          format: PdfPageImageFormat.png,
          backgroundColor: '#FFFFFF',
        );

        if (img == null) {
          throw StateError('pdfx: failed to render page ${widget.pageNumber}.');
        }

        return _RenderedPage(
          bytes: img.bytes,
          width: img.width!,
          height: img.height!,
        );
      } finally {
        await page.close();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_RenderedPage>(
      future: _renderFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: const SizedBox(
                width: double.infinity,
                height: 220,
                child: Center(child: CircularProgressIndicator(strokeWidth: 3)),
              ),
            ),
          );
        }
        if (snap.hasError) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Failed to render page ${widget.pageNumber}.\n${snap.error}',
                  style: GoogleFonts.poppins(
                    color: Colors.redAccent,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ),
          );
        }

        final pageImg = snap.data!;
        final displayWidth = MediaQuery.of(context).size.width - 32.0;
        final displayHeight = (pageImg.height / pageImg.width) * displayWidth;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: InteractiveViewer(
                clipBehavior: Clip.none,
                minScale: 1.0,
                maxScale: 5.0,
                child: Image.memory(
                  pageImg.bytes,
                  width: double.infinity,
                  height: displayHeight,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RenderedPage {
  final Uint8List bytes;
  final int width;
  final int height;
  _RenderedPage({
    required this.bytes,
    required this.width,
    required this.height,
  });
}

class _ChildTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  const _ChildTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xFF2458FF).withOpacity(0.08),
          child: Icon(icon, color: const Color(0xFF2458FF), size: 18),
        ),
        title: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: (subtitle != null && subtitle!.trim().isNotEmpty)
            ? Text(
                subtitle!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  color: Colors.black54,
                ),
              )
            : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _BottomPanel extends StatelessWidget {
  final Color color;
  final Radius radius;
  final bool expanded;
  final Widget header;
  final Widget? child;
  final Widget? collapsedBar;

  const _BottomPanel({
    required this.color,
    required this.radius,
    required this.expanded,
    required this.header,
    this.child,
    this.collapsedBar,
  });

  @override
  Widget build(BuildContext context) {
    if (!expanded) return collapsedBar ?? const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        const double kMinForHeader = 120.0;
        const double kMinForBody = 180.0;

        final h = constraints.maxHeight;
        if (h < kMinForHeader) return collapsedBar ?? const SizedBox.shrink();

        final hasRoomForBody = h >= kMinForBody;

        return Material(
          color: color,
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.only(topLeft: radius, topRight: radius),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: 4),
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: header,
              ),
              if (hasRoomForBody && child != null) ...[
                const SizedBox(height: 6),
                Flexible(
                  fit: FlexFit.loose,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: radius,
                      topRight: radius,
                    ),
                    child: child!,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _BackLevelButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _BackLevelButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 14),
      child: SizedBox(
        width: double.infinity,
        child: TextButton.icon(
          onPressed: onTap,
          icon: const Icon(
            Icons.arrow_upward_rounded,
            color: Colors.white,
            size: 18,
          ),
          label: Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.white.withOpacity(0.28)),
            ),
            backgroundColor: Colors.white.withOpacity(0.12),
          ),
        ),
      ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  final String title;
  final IconData leadingIcon;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _PanelHeader({
    required this.title,
    required this.leadingIcon,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _IconBadge(icon: leadingIcon),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              trailing ?? const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  const _IconBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}

class _Chevron extends StatelessWidget {
  final bool down;
  final Color color;
  final VoidCallback? onTap;

  const _Chevron({required this.down, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: Transform.rotate(
        angle: down ? 0 : math.pi,
        child: Icon(Icons.keyboard_arrow_up_rounded, color: color, size: 24),
      ),
    );
  }
}

class _NoContent extends StatelessWidget {
  const _NoContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No content',
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _LevelItem {
  final String type;
  final String label;
  final VoidCallback onTap;
  _LevelItem(this.type, this.label, this.onTap);

  factory _LevelItem.overview({
    required String label,
    required VoidCallback onTap,
  }) => _LevelItem('overview', label, onTap);
  factory _LevelItem.content({
    required String label,
    required VoidCallback onTap,
  }) => _LevelItem('content', label, onTap);
  factory _LevelItem.assessment({
    required String label,
    required VoidCallback onTap,
  }) => _LevelItem('assessment', label, onTap);
}

class _LevelList extends StatelessWidget {
  final List<_LevelItem> items;
  const _LevelList({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final item = items[i];
        final isOverview = item.type == 'overview';
        final isAssessment = item.type == 'assessment';

        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: item.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(isOverview ? 0.26 : 0.14),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                width: isOverview ? 1.2 : 1,
                color: Colors.white.withOpacity(isOverview ? 0.85 : 0.25),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  isOverview
                      ? Icons.menu_book_rounded
                      : (isAssessment
                            ? Icons.quiz_outlined
                            : Icons.menu_book_outlined),
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.label,
                    softWrap: true,
                    overflow: TextOverflow.visible,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: isOverview
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white, size: 18),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CollapsedBar extends StatelessWidget {
  final Color color;
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const _CollapsedBar({
    required this.color,
    required this.title,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      child: InkWell(
        onTap: onTap,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_up_rounded,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
