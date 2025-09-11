import 'package:Adaptive/config/routes.dart';
import 'package:flutter/material.dart';
import 'package:Adaptive/config/constants.dart';
import 'package:Adaptive/controllers/api_response.dart';
import 'package:Adaptive/controllers/teacher/teacher_subject_students_controller.dart';
import 'package:Adaptive/views/teacher/teacher_global_layout.dart';
import 'package:Adaptive/widgets/app_bar.dart';
import 'package:Adaptive/widgets/global_chat_widget.dart';
import 'package:Adaptive/widgets/global_chip.dart';
import 'package:get/get.dart';

class TeacherStudentPage extends StatefulWidget {
  const TeacherStudentPage({super.key});

  @override
  State<TeacherStudentPage> createState() => _TeacherStudentPageState();
}

class _TeacherStudentPageState extends State<TeacherStudentPage> {
  bool _loading = true;
  String? _error;

  int? _subjectId;
  int? _sectionId;
  String _subjectName = 'Subject';
  String _sectionName = '';

  List<Map<String, dynamic>> _students = [];

  @override
  void initState() {
    super.initState();
    _readArgs();
    _loadStudents();
  }

  void _readArgs() {
    final args = Get.arguments is Map ? (Get.arguments as Map) : const {};
    _subjectId = args['subjectId'] is int ? args['subjectId'] as int : int.tryParse('${args['subjectId'] ?? ''}');
    _sectionId = args['sectionId'] is int ? args['sectionId'] as int : int.tryParse('${args['sectionId'] ?? ''}');
    _subjectName = (args['subject_name'] ?? args['subjectName'] ?? 'Subject').toString();
    _sectionName = (args['section_name'] ?? args['sectionName'] ?? '').toString();

    print('👥 TeacherStudentPage args => '
        'subjectId=$_subjectId | subjectName=$_subjectName | '
        'sectionId=$_sectionId | sectionName=$_sectionName');
  }

  Future<void> _loadStudents() async {
    if (_subjectId == null || _subjectId! <= 0) {
      setState(() {
        _loading = false;
        _error = 'Missing subjectId.';
      });
      print('❌ Cannot load students: missing/invalid subjectId.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    print('📡 Fetching students for subjectId=$_subjectId (sectionId=$_sectionId)…');

    final ApiResponse<Map<String, dynamic>> resp =
        await TeacherSubjectStudentController.fetchSubjectStudents(
      subjectId: _subjectId!,
      sectionId: _sectionId, // optional
      // query: 'emma',      // optional
      // page: 1,            // optional (if your API paginates)
      // perPage: 50,        // optional
    );

    if (!mounted) return;

    if (!resp.success) {
      print('❌ Students fetch failed: ${resp.message}');
      setState(() {
        _loading = false;
        _error = resp.message ?? 'Failed to load students.';
      });
      return;
    }

    final raw = resp.data ?? {};
    final students = (raw['students'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
        .toList();

    print('✅ Students loaded: ${students.length}');
    for (final s in students) {
      print('• ${s['firstname']} ${s['lastname']} '
          '| section=${s['section_name']} '
          '| level=${s['level_name']} '
          '| sy=${s['sy_name']}');
    }

    setState(() {
      _students = students;
      _loading = false;

      // If you also returned subject/section info from backend, you can refresh page labels:
      final subject = (raw['subject'] as Map?)?.map((k, v) => MapEntry(k.toString(), v)) ?? {};
      _subjectName = (_subjectName.isNotEmpty ? _subjectName : '${subject['subject_name'] ?? _subjectName}').toString();
      final section = (raw['section'] as Map?)?.map((k, v) => MapEntry(k.toString(), v)) ?? {};
      _sectionName = (_sectionName.isNotEmpty ? _sectionName : '${section['section_name'] ?? ''}').toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: GlobalAppBar(
        title: 'Students',
        subtitle: _subjectName, // ✅ subtitle shows the subject name
        showBack: true,
      ),
      body: TeacherGlobalLayout(
        child: RefreshIndicator(
          onRefresh: _loadStudents,
          child: _buildBody(),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 10,
          child: SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.mainColorTheme,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                Get.toNamed(AppRoutes.addStudent, arguments: {
                  'subjectId': _subjectId,
                  'subject_name': _subjectName,
                  'sectionId': _sectionId,
                  'section_name': _sectionName,
                });
              },
              child: const Text(
                'Add Student',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _errorView(_error!);
    }
    if (_students.isEmpty) {
      return _emptyView('No students found for this subject.');
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            CustomChip(
              backgroundColor: Colors.black,
              textColor: Colors.white,
              borderColor: Colors.transparent,
              chipTitle: 'Date added',
              iconData: Icons.access_time,
            ),
            const SizedBox(width: 5),
            CustomChip(
              backgroundColor: Colors.transparent,
              textColor: Colors.black,
              borderColor: Colors.black54,
              chipTitle: 'A-Z',
              iconData: Icons.filter_alt,
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Render students
        ..._students.map((s) {
          final first = (s['firstname'] ?? '').toString().trim();
          final last = (s['lastname'] ?? '').toString().trim();
          final name = [first, last].where((v) => v.isNotEmpty).join(' ');
          final level = (s['level_name'] ?? '').toString();
          final section = (s['section_name'] ?? '').toString();
          final sectionLine = [
            if (level.isNotEmpty) level,
            if (section.isNotEmpty) section,
          ].join(' - ');

          return GlobalChatWidget(
            studentName: name.isEmpty ? 'Unknown Student' : name,
            section: sectionLine.isEmpty ? '—' : sectionLine,
          );
        }),
      ],
    );
  }

  Widget _errorView(String msg) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Text(msg, style: const TextStyle(color: Colors.red)),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _loadStudents,
          child: const Text('Retry'),
        ),
      ],
    );
    }

  Widget _emptyView(String msg) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Text(msg, textAlign: TextAlign.center),
      ],
    );
  }
}
