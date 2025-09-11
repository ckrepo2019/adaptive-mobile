import 'package:flutter/material.dart';
import 'package:Adaptive/controllers/teacher/teacher_sections_controller.dart';
import 'package:Adaptive/views/teacher/teacher_global_layout.dart';
import 'package:Adaptive/widgets/app_bar.dart';
import 'package:Adaptive/widgets/global_subject_widget.dart';
import 'package:google_fonts/google_fonts.dart';

import 'subject_classes.dart';

class TeacherSectionsPage extends StatefulWidget {
  const TeacherSectionsPage({super.key});

  @override
  State<TeacherSectionsPage> createState() => _TeacherSectionsPageState();
}

class _TeacherSectionsPageState extends State<TeacherSectionsPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _sections = [];

  @override
  void initState() {
    super.initState();
    _loadSections();
  }

  Future<void> _loadSections() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final resp = await TeacherSectionsController.fetchSections();
    if (!mounted) return;

    if (!resp.success) {
      setState(() {
        _error = resp.message ?? 'Failed to load sections.';
        _loading = false;
      });
      return;
    }

    final rawSections = (resp.data?['sections'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
        .toList();

    setState(() {
      _sections = rawSections;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadSections, child: const Text('Retry'))
          ],
        ),
      );
    } else if (_sections.isEmpty) {
      body = Center(
        child: Text(
          'No sections found.',
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
        ),
      );
    } else {
      body = ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _sections.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final s = _sections[index];
          final sectionId = s['id'] as int?;
          final sectionName = (s['section_name'] ?? 'Unnamed').toString();
          final levelName = (s['level_name'] ?? '—').toString();
          final syName = (s['sy_name'] ?? '').toString();
          final subjectsCount = (s['subjects_count'] ?? 0).toString();
          final studentsCount = (s['students_count'] ?? '—').toString();

          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TeacherSubjectClasses(
                    sectionName: sectionName,
                    sectionId: sectionId, // ✅ Pass sectionId here
                  ),
                ),
              );
            },
            child: GlobalSubjectWidget(
              classCode: sectionName,
              subject: '$levelName · $syName',
              time: 'Subjects: $subjectsCount',
              teacherName: 'Students: $studentsCount',
              imageUrl: null,
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: GlobalAppBar(title: 'My Sections', showBack: true),
      body: TeacherGlobalLayout(
        child: RefreshIndicator(onRefresh: _loadSections, child: body),
      ),
    );
  }
}
