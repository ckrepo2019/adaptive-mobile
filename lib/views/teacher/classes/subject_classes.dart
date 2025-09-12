import 'package:flutter/material.dart';
import 'package:Adaptive/controllers/teacher/teacher_class_subjects.dart';
import 'package:Adaptive/views/teacher/teacher_global_layout.dart';
import 'package:Adaptive/widgets/app_bar.dart';
import 'package:Adaptive/widgets/global_subject_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:Adaptive/utils/schedule_utils.dart';
import 'package:Adaptive/config/routes.dart';

class TeacherSubjectClasses extends StatefulWidget {
  final String sectionName;
  final int? sectionId;

  const TeacherSubjectClasses({
    super.key,
    required this.sectionName,
    this.sectionId,
  });

  @override
  State<TeacherSubjectClasses> createState() => _TeacherSubjectClassesState();
}

class _TeacherSubjectClassesState extends State<TeacherSubjectClasses> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _subjects = [];

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final resp = await TeacherSubjectController.fetchSubjects();
    if (!mounted) return;

    if (resp.success) {
      final rawSubjects = (resp.data?['subjects'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
          .toList();

      final filtered = rawSubjects
          .where((s) => (s['section_name'] ?? '').toString() == widget.sectionName)
          .toList();

      setState(() {
        _subjects = filtered;
        _loading = false;
      });
    } else {
      setState(() {
        _error = resp.message ?? 'Failed to load subjects.';
        _loading = false;
      });
    }
  }

  void _openSubjectOverview(Map<String, dynamic> subject) {
    final subjectId = subject['id'] as int?;
    final subjectName = (subject['subject_name'] ?? 'Unnamed').toString();
    final subjectCode = (subject['subject_code'] ?? '—').toString();
    final sectionName = (subject['section_name'] ?? widget.sectionName).toString();
    final levelName = (subject['level_name'] ?? '').toString();
    final teacherFullname = (subject['teacher_fullname'] ?? 'TBA').toString();
    final imageUrl = subject['image']?.toString();
    final sectionId = subject['section_id'] as int? ?? widget.sectionId; // ✅

    Get.toNamed(
      AppRoutes.teacherSubjectOverview,
      arguments: {
        'subjectId': subjectId,
        'subjectName': subjectName,
        'subjectCode': subjectCode,
        'sectionName': sectionName,
        'sectionId': sectionId, // ✅ Forward sectionId
        'levelName': levelName,
        'teacherFullname': teacherFullname,
        'image': imageUrl,
      },
    );
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
            ElevatedButton(onPressed: _loadSubjects, child: const Text('Retry'))
          ],
        ),
      );
    } else if (_subjects.isEmpty) {
      body = Center(
        child: Text(
          'No subjects found for ${widget.sectionName}.',
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
        ),
      );
    } else {
      body = ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _subjects.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final subject = _subjects[index];
          final subjectCode = subject['subject_code']?.toString() ?? '—';
          final subjectName = subject['subject_name']?.toString() ?? 'Unnamed';
          final teacherName = subject['teacher_fullname']?.toString() ?? 'TBA';
          final imageUrl = subject['image']?.toString();
          final scheduleRaw = subject['subjectsched'] as List<dynamic>?;
          final scheduleStr = ScheduleUtils.formatSchedule(scheduleRaw);
          final schedule = scheduleStr.isEmpty ? 'Schedule TBA' : scheduleStr;

          return GestureDetector(
            onTap: () => _openSubjectOverview(subject),
            child: GlobalSubjectWidget(
              classCode: subjectCode,
              subject: subjectName,
              time: schedule,
              teacherName: teacherName,
              imageUrl: imageUrl,
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: GlobalAppBar(title: widget.sectionName, showBack: true),
      body: TeacherGlobalLayout(
        child: RefreshIndicator(onRefresh: _loadSubjects, child: body),
      ),
    );
  }
}
