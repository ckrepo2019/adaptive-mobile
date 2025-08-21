import 'package:flutter/material.dart';
import 'package:flutter_lms/views/student/home/student_global_layout.dart';
import 'package:flutter_lms/widgets/app_bar.dart';
import 'package:flutter_lms/widgets/global_basic_information_widget.dart';
import 'package:flutter_lms/widgets/global_chip.dart';

class AssignmentHomePage extends StatelessWidget {
  const AssignmentHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: GlobalAppBar(showBack: true, title: 'Assignments'),
      body: GlobalLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomChip(
                backgroundColor: Colors.black,
                textColor: Colors.white,
                borderColor: Colors.black54,
                chipTitle: 'Ongoing',
                iconData: Icons.access_time,
              ),
              SizedBox(width: screenWidth * 0.02),
              CustomChip(
                backgroundColor: Colors.white,
                textColor: Colors.black54,
                borderColor: Colors.black54,
                chipTitle: 'Finished',
                iconData: Icons.archive_outlined,
              ),
            ],
          ),

          SizedBox(height: 15,),

          GlobalBasicInformationWidget(classTitle: 'Math Quiz: Quadratic Equations', subject: 'Mathematics', time: '3:00 PM', duration: '20 min'),
          GlobalBasicInformationWidget(classTitle: 'Chemical Reaction Assignment', subject: 'Mathematics', time: '3:00 PM', duration: '20 min'),
        ],
      ),
      ),
    );
  }
}