import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Adaptive/config/constants.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _students = [];

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  /// Safely parse arguments from GetX.
  dynamic _getArg(String key) {
    final args = Get.arguments as Map? ?? {};
    return args[key];
  }

  /// Fetch students for the attendance page.
  Future<void> _fetchStudents() async {
    final subjectId = _getArg('subjectId');
    if (subjectId == null) {
      setState(() {
        _error = 'No subject ID provided.';
        _loading = false;
      });
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('No token found.');

      final url = Uri.parse('${AppConstants.baseURL}/teacher/subjects/$subjectId/students');
      final res = await http.get(url, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      final body = jsonDecode(res.body);

      if (res.statusCode == 200 && body['success'] == true) {
        final students = (body['students'] as List?)
                ?.map((e) => Map<String, dynamic>.from(e))
                .toList() ??
            [];
        setState(() {
          _students = students;
          _loading = false;
        });
      } else {
        setState(() {
          _error = body['message'] ?? 'Failed to load students.';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error fetching students: $e';
        _loading = false;
      });
    }
  }

  /// Builds a status button for attendance states.
  Widget _attendanceButton(String text, Color color) {
    return Container(
      width: 110,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subjectName = _getArg('subjectName') ?? 'Attendance';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            Text(
              subjectName,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10, top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _attendanceButton('Present', Colors.green),
                _attendanceButton('Late', Colors.orange),
                _attendanceButton('Absent', Colors.red),
              ],
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _errorView(_error!)
              : _students.isEmpty
                  ? const Center(child: Text('No students found.'))
                  : _studentsList(),
    );
  }

  Widget _errorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          message,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _studentsList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: _students.length,
      itemBuilder: (context, index) {
        final s = _students[index];
        final name = '${s['firstname']} ${s['lastname']}';
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(value: false, onChanged: (v) {}),
                  Text(name),
                ],
              ),
              Switch(
                value: true,
                onChanged: (v) {},
                activeColor: Colors.green,
              ),
            ],
          ),
        );
      },
    );
  }
}
