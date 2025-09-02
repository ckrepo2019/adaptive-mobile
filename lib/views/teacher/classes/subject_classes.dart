import 'package:flutter/material.dart';
import 'package:flutter_lms/controllers/teacher/teacher_class_subjects.dart';
import 'package:flutter_lms/views/teacher/teacher_global_layout.dart';
import 'package:flutter_lms/widgets/app_bar.dart';
import 'package:flutter_lms/widgets/global_subject_widget.dart';
import 'package:google_fonts/google_fonts.dart';

// ⬇️ Adjust the import path to where you saved the utils file
import 'package:flutter_lms/utils/schedule_utils.dart';

class TeacherSubjectClasses extends StatefulWidget {
  const TeacherSubjectClasses({super.key});

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

    print('🔍 Fetching subjects from API...');
    final resp = await TeacherSubjectController.fetchSubjects();

    if (!mounted) return;
    print('📥 Raw API Response: ${resp.data}');

    if (resp.success) {
      final rawSubjects = (resp.data?['subjects'] as List<dynamic>? ?? []);
      final rawHeaders = (resp.data?['subjectHeaders'] as List<dynamic>? ?? []);

      print('📊 subjects length: ${rawSubjects.length}');
      print('📊 subjectHeaders length: ${rawHeaders.length}');

      final subjects = rawSubjects
          .whereType<Map>()
          .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
          .toList();

      final headers = rawHeaders
          .whereType<Map>()
          .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
          .toList();

      // Merge headers for missing subject codes
      final subjectCodes = subjects.map((s) => s['subject_code']).toSet();
      for (final header in headers) {
        if (!subjectCodes.contains(header['subject_code'])) {
          print('➕ Adding subjectHeader fallback: ${header['subject_code']}');
          subjects.add(header);
        }
      }

      print('✅ Final merged subjects count: ${subjects.length}');

      setState(() {
        _subjects = subjects;
        _loading = false;
      });
    } else {
      print('❌ Failed to load subjects: ${resp.message}');
      setState(() {
        _error = resp.message ?? 'Failed to load subjects.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadSubjects,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    } else if (_subjects.isEmpty) {
      print('⚠️ No subjects to display.');
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No subjects found.',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      body = ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _subjects.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final subject = _subjects[index];

          // Extract values (handle both subjects & headers)
          final subjectCode = subject['subject_code']?.toString() ?? '—';
          final subjectName =
              subject['subject_name']?.toString() ?? 'Unnamed Subject';

          // Compose teacher name more safely (firstname + lastname if available)
          final first = (subject['firstname'] ?? '').toString().trim();
          final last = (subject['lastname'] ?? '').toString().trim();
          final teacherName = [first, last].where((s) => s.isNotEmpty).join(' ');

          final imageUrl = subject['image']?.toString();

          // ✅ Use ScheduleUtils to format schedule nicely
          final scheduleRaw = subject['subjectsched'] as List<dynamic>?;
          final scheduleStr = ScheduleUtils.formatSchedule(scheduleRaw);
          final schedule = (scheduleStr.isEmpty) ? 'Schedule TBA' : scheduleStr;

          print(
              '🎓 Subject [$subjectCode]: $subjectName | Teacher: ${teacherName.isEmpty ? 'TBA' : teacherName} | Schedule: $schedule');

          return GlobalSubjectWidget(
            classCode: subjectCode,
            subject: subjectName,
            time: schedule,
            teacherName: teacherName.isEmpty ? 'TBA' : teacherName,
            imageUrl: imageUrl,
          );
        },
      );
    }

    return Scaffold(
      appBar: GlobalAppBar(title: 'Subject Classes', showBack: true),
      body: TeacherGlobalLayout(
        child: RefreshIndicator(
          onRefresh: _loadSubjects,
          child: body,
        ),
      ),
    );
  }
}
