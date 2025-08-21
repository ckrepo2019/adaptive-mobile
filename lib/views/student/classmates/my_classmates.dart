import 'package:flutter/material.dart';
import 'package:flutter_lms/views/student/home/student_global_layout.dart';
import 'package:flutter_lms/widgets/app_bar.dart';
import 'package:flutter_lms/widgets/global_chat_widget.dart';
import 'package:flutter_lms/widgets/global_chip.dart';
import 'package:flutter_lms/widgets/ui_widgets.dart';

class StudentMyClassmatePage extends StatelessWidget {
  const StudentMyClassmatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: GlobalAppBar(
        title: 'My Classmates',
        subtitle: 'Essential Algebra',
        showBack: true,
      ),
      body: GlobalLayout(child: Column(
        children: [
          SizedBox(height: 10,),
          Row(
            children: [
              CustomChip(backgroundColor: Colors.black, textColor: Colors.white, borderColor: Colors.black, chipTitle: 'Date added', iconData: Icons.access_time,),
              Spacer(),
              Icon(Icons.search, color: Colors.black54,),
            ],
          ),

          SizedBox(height: 20,),

          GlobalChatWidget(studentName: 'Emma Watsons', section: 'Grade 7 - Emerald',),
          GlobalChatWidget(studentName: 'Emma Watsons', section: 'Grade 7 - Emerald',),
          GlobalChatWidget(studentName: 'Emma Watsons', section: 'Grade 7 - Emerald',),
          GlobalChatWidget(studentName: 'Emma Watsons', section: 'Grade 7 - Emerald',),
          GlobalChatWidget(studentName: 'Emma Watsons', section: 'Grade 7 - Emerald',),
          GlobalChatWidget(studentName: 'Emma Watsons', section: 'Grade 7 - Emerald',),
        ],
      )),
    );
  }
}

