import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:Adaptive/config/constants.dart';
import 'package:Adaptive/config/routes.dart';
import 'package:Adaptive/controllers/api_response.dart';
import 'package:Adaptive/controllers/teacher/teacher_subject_students_controller.dart';
import 'package:Adaptive/views/teacher/teacher_global_layout.dart';
import 'package:Adaptive/widgets/app_bar.dart';
import 'package:Adaptive/widgets/global_chat_widget.dart';
import 'package:Adaptive/widgets/global_chip.dart';

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

  /// Reads arguments passed via GetX routing.
  void _readArgs() {
    final args = Get.arguments is Map ? (Get.arguments as Map) : {};
    _subjectId = _parseId(args['subjectId']);
    _sectionId = _parseId(args['sectionId']);
    _subjectName = (args['subject_name'] ?? args['subjectName'] ?? 'Subject').toString();
    _sectionName = (args['section_name'] ?? args['sectionName'] ?? '').toString();

    debugPrint(
      '👥 Args => subjectId=$_subjectId | subjectName=$_subjectName | '
      'sectionId=$_sectionId | sectionName=$_sectionName',
    );
  }

  int? _parseId(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  /// Loads students for the given subject/section.
  Future<void> _loadStudents() async {
    if (_subjectId == null || _subjectId! <= 0) {
      setState(() {
        _loading = false;
        _error = 'Missing subjectId.';
      });
      debugPrint('❌ Missing/invalid subjectId.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    debugPrint('📡 Fetching students for subjectId=$_subjectId (sectionId=$_sectionId)…');

    final resp = await TeacherSubjectStudentController.fetchSubjectStudents(
      subjectId: _subjectId!,
      sectionId: _sectionId,
    );

    if (!mounted) return;

    if (!resp.success) {
      setState(() {
        _loading = false;
        _error = resp.message ?? 'Failed to load students.';
      });
      debugPrint('❌ Fetch failed: ${resp.message}');
      return;
    }

    final raw = resp.data ?? {};
    final students = (raw['students'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
        .toList();

    debugPrint('✅ Students loaded: ${students.length}');
    for (final s in students) {
      debugPrint('• ${s['firstname']} ${s['lastname']} '
          '| section=${s['section_name']} '
          '| level=${s['level_name']} '
          '| sy=${s['sy_name']}');
    }

    setState(() {
      _students = students;
      _loading = false;

      // Update labels if backend provides subject/section info.
      final subject = (raw['subject'] as Map?)?.map((k, v) => MapEntry(k.toString(), v)) ?? {};
      _subjectName = _subjectName.isNotEmpty
          ? _subjectName
          : (subject['subject_name'] ?? _subjectName).toString();

      final section = (raw['section'] as Map?)?.map((k, v) => MapEntry(k.toString(), v)) ?? {};
      _sectionName = _sectionName.isNotEmpty
          ? _sectionName
          : (section['section_name'] ?? '').toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: GlobalAppBar(
        title: 'Students',
        subtitle: _subjectName,
        showBack: true,
      ),
      body: TeacherGlobalLayout(
        child: RefreshIndicator(
          onRefresh: _loadStudents,
          child: _buildBody(),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _errorView(_error!);
    if (_students.isEmpty) return _emptyView('No students found for this subject.');

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
        ..._students.map((s) {
          final name = _fullName(s);
          final sectionLine = _sectionLine(s);
          return GlobalChatWidget(
            studentName: name.isEmpty ? 'Unknown Student' : name,
            section: sectionLine.isEmpty ? '—' : sectionLine,
          );
        }),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Padding(
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
    );
  }

  String _fullName(Map<String, dynamic> s) {
    final first = (s['firstname'] ?? '').toString().trim();
    final last = (s['lastname'] ?? '').toString().trim();
    return [first, last].where((v) => v.isNotEmpty).join(' ');
  }

  String _sectionLine(Map<String, dynamic> s) {
    final level = (s['level_name'] ?? '').toString();
    final section = (s['section_name'] ?? '').toString();
    return [if (level.isNotEmpty) level, if (section.isNotEmpty) section].join(' - ');
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
