import 'package:flutter/material.dart';
import 'package:flutter_lms/config/constants.dart';
import 'package:flutter_lms/controllers/teacher/teacher_book_controller.dart';
import 'package:flutter_lms/views/teacher/books-assigned/book_details.dart';
import 'package:Adaptive/views/teacher/teacher_global_layout.dart';
import 'package:Adaptive/widgets/app_bar.dart';
import 'package:Adaptive/widgets/global_books_widget.dart';
import 'package:Adaptive/widgets/global_chip.dart';
// import 'package:Adaptive/config/routes.dart'; // ← if you’ll navigate to an overview page later
// import 'package:get/get.dart';

class AssignedBooksPage extends StatefulWidget {
  const AssignedBooksPage({super.key});

  @override
  State<AssignedBooksPage> createState() => _AssignedBooksPageState();
}

class _AssignedBooksPageState extends State<AssignedBooksPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _books = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    print('📚 Fetching assigned books (teacher-only)…');
    final resp = await TeacherBookController.fetchBooks();

    if (!mounted) return;

    if (!resp.success) {
      print('❌ Books fetch failed: ${resp.message}');
      setState(() {
        _loading = false;
        _error = resp.message ?? 'Failed to load books.';
      });
      return;
    }

    final list = (resp.data?['books'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
        .toList();

    print('✅ Received ${list.length} assigned books');
    for (final b in list) {
      print(
        '• id=${b['bookID']} | title=${b['courseware_name']} | created_at=${b['created_at']} '
        '| teachers=${(b['teachers'] as List?)?.length ?? 0} | collaborators=${(b['collaborators'] as List?)?.length ?? 0}',
      );
    }

    setState(() {
      _books = list;
      _loading = false;
    });
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    try {
      final dt = DateTime.parse(iso);
      return '${_month(dt.month)} ${dt.day}, ${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  String _month(int m) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return (m >= 1 && m <= 12) ? names[m - 1] : '—';
  }

  String? _resolveImage(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final s = raw.trim();
    final l = s.toLowerCase();
    if (l.startsWith('http://') || l.startsWith('https://')) return s;

    final base = AppConstants.imageBaseUrl;
    final hasSlash = base.endsWith('/');
    final leadSlash = s.startsWith('/');
    return hasSlash && leadSlash
        ? '$base${s.substring(1)}'
        : (!hasSlash && !leadSlash ? '$base/$s' : '$base$s');
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_loading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      content = Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    } else if (_books.isEmpty) {
      content = const Center(child: Text('No books assigned yet.'));
    } else {
      content = RefreshIndicator(
        onRefresh: _load,
        child: ListView.separated(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          itemCount: _books.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final b = _books[index];

            final title = (b['courseware_name'] ?? 'Untitled Courseware')
                .toString();
            final created = _formatDate(b['created_at']?.toString());
            final img = _resolveImage(b['image']?.toString());

            // We don’t have grade levels or true “total sections” in this teacher-only payload.
            // For now, show a placeholder for grade_level and use number of teacher assignees
            // as a lightweight “count” in the totalSections slot (you can rename the label in your widget later).
            final teacherCount = (b['teachers'] is List)
                ? (b['teachers'] as List).length
                : 0;

            // If you want tap -> book overview later, wrap with GestureDetector and navigate:
            // return GestureDetector(
            //   onTap: () => Get.toNamed(AppRoutes.teacherBookOverview, arguments: {'bookID': b['bookID']}),
            //   child: GlobalBooksWidget(...),
            // );

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookDetailsPage(bookId: b['bookID']),
                  ),
                );
              },
              child: GlobalBooksWidget(
                grade_level: '—',
                totalSections: '$teacherCount',
                dateAssined: created,
                subject: title,
                imageUrl: img ?? '',
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: const GlobalAppBar(
        title: 'Books Assigned',
        showBack: true,
        showNotifications: false,
        showProfile: false,
      ),
      body: TeacherGlobalLayout(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            children: [
              Row(
                children: [
                  CustomChip(
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    borderColor: Colors.transparent,
                    chipTitle: 'Date Added',
                    iconData: Icons.access_time,
                  ),
                  const SizedBox(width: 8),
                  CustomChip(
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    borderColor: Colors.grey.shade500,
                    chipTitle: 'Most Recent',
                    iconData: Icons.update,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      // hook up a search/filter later if needed
                      print('🔎 Search tapped');
                    },
                    icon: const Icon(Icons.search),
                    tooltip: 'Search books',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(child: content),
            ],
          ),
        ),
      ),
    );
  }
}
