import 'package:flutter/material.dart';
import 'package:flutter_lms/controllers/teacher/teacher_class_subjects.dart';
import 'package:flutter_lms/views/utilities/layouts/global_layout.dart';
import 'package:flutter_lms/widgets/app_bar.dart';
import 'package:flutter_lms/widgets/ui_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class TeacherSubjectClasses extends StatefulWidget {
  const TeacherSubjectClasses({super.key});

  @override
  State<TeacherSubjectClasses> createState() => _SubjectClassesState();
}

class _SubjectClassesState extends State<TeacherSubjectClasses> {
  bool _loading = true;
  String? _error;
  List<dynamic> _subjectList = [];

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    final resp = await TeacherSubjectController.fetchSubjects();
    if (!mounted) return;
    if (resp.success) {
      setState(() {
        _subjectList = resp.data?['subjectlist'] ?? [];
        _loading = false;
      });
    } else {
      setState(() {
        _error = resp.message ?? 'Failed to load subjects.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (_loading) {
      return const Scaffold(
        appBar: GlobalAppBar(title: 'Subject Classes', showBack: true),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: const GlobalAppBar(title: 'Subject Classes', showBack: true),
        body: Center(
          child: Text(
            _error!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: const GlobalAppBar(title: 'Subject Classes', showBack: true),
      body: StudentGlobalLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Header card
            Card(
              elevation: 10,
              child: Container(
                width: double.infinity,
                height: screenHeight * 0.18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0034F8),
                      Color(0xFF082BAB),
                    ],
                    stops: [0.1, 0.8],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: -15,
                      child: Image.asset(
                        'assets/images/utilities/student_throw_cap.png',
                        width: screenWidth * 0.45,
                        height: screenHeight * 0.45,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(screenWidth * 0.06),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "My Classes",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _subjectList.isNotEmpty
                                ? _subjectList[0]['subject_name'] ?? 'Unknown'
                                : 'No subjects',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.09,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Icon(Icons.person_2),
                const SizedBox(width: 5),
                Text(
                  "Sections",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ✅ Dynamic list of sections
            Expanded(
              child: ListView.builder(
                itemCount: _subjectList.length,
                itemBuilder: (context, index) {
                  final subject = _subjectList[index];
                  final sectionName =
                      subject['section_name'] ?? 'Unknown Section';
                  final classCode = subject['class_code'] ?? '---';
                  final studentCount =
                      subject['students_count']?.toString() ?? '0';

                  return SectionsCard(
                    sectionName: sectionName,
                    classCode: classCode,
                    studentCount: studentCount,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionsCard extends StatelessWidget {
  final String sectionName;
  final String classCode;
  final String studentCount;

  const SectionsCard({
    super.key,
    required this.sectionName,
    required this.classCode,
    required this.studentCount,
  });

  @override
  Widget build(BuildContext context) {
    return InkCardShell(
      leftAccent: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sectionName,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text("Class Code: $classCode"),
          const SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(Icons.person, color: Colors.grey.shade500),
              const SizedBox(width: 5),
              Text(
                "$studentCount Students",
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
