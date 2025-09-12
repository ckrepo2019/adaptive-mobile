import 'package:flutter/material.dart';
import 'package:Adaptive/config/constants.dart';
import 'package:Adaptive/controllers/teacher/teacher_book_controller.dart';
import 'package:Adaptive/views/teacher/books-assigned/book_details.dart';
import 'package:Adaptive/views/teacher/teacher_global_layout.dart';
import 'package:Adaptive/widgets/app_bar.dart';
import 'package:Adaptive/widgets/global_books_widget.dart';
import 'package:Adaptive/widgets/global_chip.dart';

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
    _loadBooks();
  }

  /// Fetch assigned books for the teacher.
  Future<void> _loadBooks() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    debugPrint('📚 Fetching assigned books…');
    final resp = await TeacherBookController.fetchBooks();

    if (!mounted) return;

    if (!resp.success) {
      debugPrint('❌ Fetch failed: ${resp.message}');
      setState(() {
        _error = resp.message ?? 'Failed to load books.';
        _loading = false;
      });
      return;
    }

    final books = (resp.data?['books'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
        .toList();

    debugPrint('✅ Loaded ${books.length} books.');
    setState(() {
      _books = books;
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
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return (m >= 1 && m <= 12) ? names[m - 1] : '—';
  }

  String? _resolveImage(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final s = raw.trim();
    final l = s.toLowerCase();
    if (l.startsWith('http://') || l.startsWith('https://')) return s;

    final base = AppConstants.imageBaseUrl;
    final needsSlash =
        (base.endsWith('/') && s.startsWith('/')) ? s.substring(1) : s;
    return base.endsWith('/') || s.startsWith('/')
        ? '$base$needsSlash'
        : '$base/$needsSlash';
  }

  @override
  Widget build(BuildContext context) {
    final content = _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
            ? _errorView(_error!)
            : _books.isEmpty
                ? const Center(child: Text('No books assigned yet.'))
                : RefreshIndicator(
                    onRefresh: _loadBooks,
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      itemCount: _books.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final book = _books[index];
                        final title =
                            (book['courseware_name'] ?? 'Untitled Courseware')
                                .toString();
                        final created = _formatDate(
                            book['created_at']?.toString());
                        final img = _resolveImage(book['image']?.toString());
                        final teacherCount = (book['teachers'] is List)
                            ? (book['teachers'] as List).length
                            : 0;

                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  BookDetailsPage(bookId: book['bookID']),
                            ),
                          ),
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

    return Scaffold(
      appBar: const GlobalAppBar(
        title: 'Books Assigned',
        showBack: true,
        showNotifications: false,
        showProfile: false,
      ),
      body: SafeArea(
        child: TeacherGlobalLayout(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    const CustomChip(
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
                        debugPrint('🔎 Search tapped');
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
      ),
    );
  }

  Widget _errorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadBooks, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
