import 'package:flutter/material.dart';
import 'package:flutter_lms/views/teacher/teacher_global_layout.dart';
import 'package:flutter_lms/widgets/app_bar.dart';
import 'package:flutter_lms/widgets/global_chip.dart';

class MyClassroomPage extends StatelessWidget {
  const MyClassroomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalAppBar(title: 'MyClassrooms', showBack: false, showNotifications: false, showProfile: false,),
      body: TeacherGlobalLayout(child: Column(
        children: [
          Row(
            children: [
             CustomChip(
                  backgroundColor: const Color(0xFFE6F4FF),
                  textColor: const Color(0xFF0B63CE),
                  borderColor: Colors.transparent,
                  chipTitle: 'Adviser : Ms. Celine',
                  iconData: Icons.verified_user_outlined,
                ),
                const SizedBox(width: 8),
                CustomChip(
                  backgroundColor: Colors.grey.shade300,
                  textColor: Colors.black,
                  borderColor: Colors.transparent,
                  chipTitle: '30 Students',
                  iconData: Icons.people_alt_outlined,
                ),
            ],
          ),

          SizedBox(height: 10,),

          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300)
            ),
            child: Row(
              children: [
                // Left side image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  child: Image.asset(
                    'assets/images/default-images/default-female-teacher-class.png',
                    width: 180,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                // Right side text
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Class Emerald',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'NF03SS',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Mon, Wed, Fri - 9:00 AM',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),


        ],
      )),
    );
  }
}