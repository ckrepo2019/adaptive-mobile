import 'package:Adaptive/controllers/teacher/teacher_book_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:Adaptive/widgets/app_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class BookDetailsPage extends StatefulWidget {
  const BookDetailsPage({super.key, required this.bookId});
  final int bookId;

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _book;
  List<String> _tags = [];
  List<String> _grades = [];
  List<String> _courses = [];
  List<Map<String, dynamic>> _subjects = [];

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final resp = await TeacherBookDetailsController.fetchBookDetails(
      bookId: widget.bookId,
    );

    if (!mounted) return;

    if (!resp.success) {
      setState(() {
        _loading = false;
        _error = resp.message ?? 'Failed to load book details.';
      });
      return;
    }

    setState(() {
      _book = resp.data?['book'];
      _tags = (resp.data?['tags'] as List<String>? ?? []);
      _grades = (resp.data?['grades'] as List<String>? ?? []);
      _courses = (resp.data?['courses'] as List<String>? ?? []);
      _subjects = (resp.data?['subjects'] as List<Map<String, dynamic>>? ?? []);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const brandBlue = Color(0xFF2563EB);

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: GlobalAppBar(
          title: 'Book Details',
          subtitle: 'Error',
          showNotifications: false,
          showBack: true,
          showProfile: false,
          backgroundColor: brandBlue,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _loadDetails, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final title = _book?['courseware_name'] ?? 'Untitled';
    final description = _book?['description'] ?? 'No description';
    final author = (_book?['author'] ?? 'Unknown Author').toString();
    final assignedSince = _book?['created_at']?.toString() ?? '—';
    final coverUrl = _book?['image']?.toString();

    return Scaffold(
      appBar: GlobalAppBar(
        title: 'Book Details',
        subtitle: title,
        showNotifications: false,
        showBack: true,
        showProfile: false,
        backgroundColor: brandBlue,
      ),
      backgroundColor: const Color(0xFFF3F4F6),
      body: DefaultTabController(
        length: 3,
        child: Stack(
          children: [
            // Blue header
            Container(
              height: 240,
              decoration: const BoxDecoration(
                color: brandBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.only(top: 180, bottom: 24),
              child: Column(
                children: [
                  // Book cover
                  Center(
                    child: Container(
                      width: 180,
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.12),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: coverUrl == null || coverUrl.isEmpty
                            ? Image.asset(
                                'assets/images/default-images/default-female-teacher-class.png',
                                fit: BoxFit.cover,
                              )
                            : Image.network(coverUrl, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title & author
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        author,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.verified, color: brandBlue, size: 16),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Details container
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.06),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const TabBar(
                            labelColor: brandBlue,
                            unselectedLabelColor: Colors.black54,
                            indicatorColor: brandBlue,
                            tabs: [
                              Tab(text: 'About Book'),
                              Tab(text: 'Assigned To'),
                              Tab(text: 'Learners'),
                            ],
                          ),
                          SizedBox(
                            height: 400,
                            child: TabBarView(
                              children: [
                                _AboutBookContent(
                                  title: description,
                                  assignedSince: assignedSince,
                                  tags: _tags,
                                  grades: _grades,
                                  courses: _courses,
                                ),
                                _AssignedToTab(subjects: _subjects),
                                _LearnersTab(subjects: _subjects),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Action buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: brandBlue,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: const Text('Manage Book', style: TextStyle(color: Colors.white),),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.block, color: Colors.red),
                                  style: OutlinedButton.styleFrom(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: const BorderSide(color: Colors.red),
                                  ),
                                  onPressed: () {},
                                  label: const Text(
                                    'Unassign Book',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutBookContent extends StatelessWidget {
  const _AboutBookContent({
    required this.title,
    required this.assignedSince,
    required this.tags,
    required this.grades,
    required this.courses,
  });

  final String title;
  final String assignedSince;
  final List<String> tags;
  final List<String> grades;
  final List<String> courses;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        Text(
          'About',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$title\nAssigned since $assignedSince',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        const SizedBox(height: 12),
        Text(
          'Grades: ${grades.isEmpty ? 'N/A' : grades.join(', ')}',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        const SizedBox(height: 6),

        courses.isEmpty
        ? const SizedBox.shrink()
        : Text(
            'Courses: ${courses.join(', ')}',
            style: GoogleFonts.poppins(fontSize: 14),
          ),

        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: tags.map((t) => Chip(label: Text(t))).toList(),
        ),
      ],
    );
  }
}

class _AssignedToTab extends StatelessWidget {
  final List<Map<String, dynamic>> subjects;
  const _AssignedToTab({required this.subjects});

  @override
  Widget build(BuildContext context) {
    if (subjects.isEmpty) {
      return const Center(child: Text('No classes assigned.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: subjects.length,
      itemBuilder: (_, i) {
        final s = subjects[i];
        return ListTile(
          title: Text(s['subject_name'] ?? 'Unknown Subject'),
          subtitle: Text(s['section_name'] ?? 'Section'),
          trailing: Text('${s['enrolled_students_count'] ?? 0} learners'),
        );
      },
    );
  }
}

class _LearnersTab extends StatelessWidget {
  final List<Map<String, dynamic>> subjects;
  const _LearnersTab({required this.subjects});

  @override
  Widget build(BuildContext context) {
    // Combine learners if backend adds them later
    final learners = subjects.expand((s) {
      final students = s['students'] as List<dynamic>? ?? [];
      return students;
    }).toList();

    if (learners.isEmpty) {
      return const Center(child: Text('No learners found.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: learners.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (_, i) {
        final l = learners[i] as Map<String, dynamic>;
        return ListTile(
          leading: CircleAvatar(child: Text((l['firstname'] ?? 'S')[0])),
          title: Text('${l['firstname']} ${l['lastname']}'),
          subtitle: Text(l['level_name'] ?? ''),
        );
      },
    );
  }
}
