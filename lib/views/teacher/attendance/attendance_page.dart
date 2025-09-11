import 'dart:convert';
import 'package:Adaptive/config/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<void> _fetchStudents() async {
    final args = Get.arguments as Map? ?? {};
    final subjectId = args['subjectId'];
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
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subjectName = (Get.arguments as Map?)?['subjectName'] ?? 'Attendance';

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
            Text('Attendance',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
            Text(subjectName,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
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
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(_error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center),
                  ),
                )
              : _students.isEmpty
                  ? const Center(child: Text('No students found.'))
                  : ListView.builder(
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
                    ),
    );
  }
}
