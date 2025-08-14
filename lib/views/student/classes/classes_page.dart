import 'package:flutter/material.dart';
import 'package:flutter_lms/views/student/home/student_global_layout.dart';
import 'package:flutter_lms/widgets/global_chip.dart';
import 'package:flutter_lms/widgets/global_subject_widget.dart';

class StudentClassPage extends StatelessWidget {
  const StudentClassPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StudentGlobalLayout(
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "Classes",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
              ),

              Spacer(),

              InkWell(

                // TODO : Add routes
                onTap: () => null,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(
                      MediaQuery.of(context).size.width * 0.01,
                    ),
                    child: Image.asset(
                      'assets/images/student-home/ci_bell-notification.png',
                      width: MediaQuery.of(context).size.width * 0.01,
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                  ),
                ),
              ),
              InkWell(

                // TODO : Add routes
                onTap: () => null,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(
                      MediaQuery.of(context).size.width * 0.01,
                    ),
                    child: Image.asset(
                      'assets/images/student-home/profile-icon.png',
                      width: MediaQuery.of(context).size.width * 0.01,
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          // === Badges Row ===
          Row(
            children: [
              CustomChip(
                backgroundColor: Colors.black,
                textColor: Colors.white,
                borderColor: Colors.black54,
                chipTitle: 'Current',
                iconData: Icons.access_time,
              ),
              const SizedBox(width: 8),
              CustomChip(
                backgroundColor: Colors.white,
                textColor: Colors.black54,
                borderColor: Colors.black54,
                chipTitle: 'Archived',
                iconData: Icons.archive_outlined,
              ),

              Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color.fromARGB(255, 35, 78, 244),
                ),
                child: Center(
                  child: Row(
                    children: [
                      Icon(Icons.add, size: 14, color: Colors.white),
                      SizedBox(width: 5),
                      Text("Add Class", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 25),

          GlobalSubjectWidget(
            subject: 'Mathematics', classCode: 'Math Class 101', time: 'Today, 11:00 AM', teacherName: 'Alix, John Richard',
            
          ),

          GlobalSubjectWidget(
            subject: 'Mathematics', classCode: 'Math Class 101', time: 'Today, 11:00 AM', teacherName: 'Alix, John Richard',
            
          ),
        ],
      ),
    );
  }
}

