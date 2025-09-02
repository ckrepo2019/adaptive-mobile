import 'package:flutter/material.dart';
import 'package:flutter_lms/widgets/ui_widgets.dart';

class GlobalChatWidget extends StatelessWidget {
  final String studentName;
  final String section;

  const GlobalChatWidget({super.key, required this.studentName, required this.section});

  @override
  Widget build(BuildContext context) {
    return InkCardShell(
      leftAccent: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.grey.shade500,
                ),
              ),

              SizedBox(width: 10),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    studentName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    section,
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),

              Spacer(),
              Icon(Icons.chat_bubble_outline, color: Colors.green),
              SizedBox(width: 5),
              Icon(Icons.delete_outline_outlined, color: Colors.red),
            ],
          ),
        ],
      ),
    );
  }
}
