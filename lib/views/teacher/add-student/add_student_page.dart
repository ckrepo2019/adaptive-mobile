import 'dart:async';
import 'dart:convert';
import 'package:Adaptive/controllers/teacher/teacher_add_students_controller.dart';
import 'package:flutter/material.dart';
import 'package:Adaptive/config/constants.dart';
import 'package:Adaptive/config/routes.dart';
import 'package:Adaptive/views/teacher/teacher_global_layout.dart';
import 'package:Adaptive/widgets/app_bar.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Simple model for added students
class AddedStudent {
  final String id;
  final String name;
  AddedStudent({required this.id, required this.name});
}

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key});

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final List<AddedStudent> _addedStudents = [];
  bool _loading = false;
  String? _error;

  /// Fetch a student's name from the backend using their SID
  Future<String?> _fetchStudentName(String studentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final uri = Uri.parse('${AppConstants.baseURL}/teacher/students/$studentId');

      final res = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          return '${body['student']['firstname']} ${body['student']['lastname']}';
        }
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching student: $e');
      return null;
    }
  }

  /// Handles input of a student ID (triggered by space or enter)
  Future<void> _handleInput(String value) async {
    final sid = value.trim();
    if (sid.isEmpty) return;

    setState(() => _loading = true);

    // Use TeacherAddStudentsController to fetch both internal id and name
    final resp = await TeacherAddStudentsController.getStudentBySid(sid: sid);

    setState(() => _loading = false);

    if (resp.success && resp.data != null) {
      final student = resp.data!;
      final internalId = student['id'].toString(); // internal DB id
      final name = '${student['firstname']} ${student['lastname']}';

      if (!_addedStudents.any((s) => s.id == internalId)) {
        setState(() {
          _addedStudents.add(AddedStudent(id: internalId, name: name));
        });
      }
    } else {
      setState(() => _error = resp.message ?? 'Student ID $sid not found.');
    }

    _controller.clear();
    _focusNode.requestFocus();
  }


  /// Remove a student chip
  void _removeStudent(AddedStudent s) {
    setState(() {
      _addedStudents.remove(s);
    });
  }

  /// Submit added students to the backend
  Future<void> _submitStudents() async {
    if (_addedStudents.isEmpty) {
      setState(() => _error = 'Please add at least one student.');
      return;
    }

    final args = Get.arguments ?? {};
    final subjectId = args['subjectId'];
    final sectionId = args['sectionId'];

    debugPrint('Args received: $args');

    if (subjectId == null || sectionId == null) {
      setState(() => _error = 'Missing subject or section information.');
      return;
    }

    final ids = _addedStudents
        .where((e) => e.id.isNotEmpty)
        .map((e) => int.tryParse(e.id) ?? -1)
        .where((id) => id != -1)
        .toList();

    if (ids.isEmpty) {
      setState(() => _error = 'Invalid student IDs. Please re-add.');
      return;
    }

    debugPrint('Submitting: ids=$ids, subject=$subjectId, section=$sectionId');

    setState(() {
      _loading = true;
      _error = null;
    });

    final resp = await TeacherAddStudentsController.addStudents(
      studentIds: ids,
      subjectId: subjectId,
      sectionId: sectionId,
    );

    setState(() => _loading = false);

    if (resp.success) {
      Get.toNamed(AppRoutes.teacherAddStudentSuccess);
    } else {
      setState(() => _error = resp.message ?? 'Failed to add students.');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GlobalAppBar(
        title: 'Adding students',
        subtitle: 'Essential Algebra for Beginners',
        showBack: true,
      ),
      body: TeacherGlobalLayout(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 25),
              Center(
                child: Image.asset(
                  'assets/images/utilities/students.png',
                  height: 200,
                  width: 200,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Add students",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 25),

              // Chips for added students
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _addedStudents
                    .map((s) => Chip(
                          label: Text('${s.id} - ${s.name}'),
                          deleteIcon: const Icon(Icons.close),
                          onDeleted: () => _removeStudent(s),
                        ))
                    .toList(),
              ),

              const SizedBox(height: 12),

              // Input field
              Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    textAlign: TextAlign.left,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      hintText: "Type Student ID and press space or enter",
                      border: InputBorder.none,
                    ),
                    onSubmitted: _handleInput,
                    onChanged: (val) {
                      if (val.endsWith(' ')) {
                        _handleInput(val);
                      }
                    },
                  ),
                ),
              ),

              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: CircularProgressIndicator(),
                ),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              const Spacer(),

              ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text('Submit Students'),
                onPressed: _submitStudents,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
