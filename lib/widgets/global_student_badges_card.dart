import 'package:flutter/material.dart';
import 'package:flutter_lms/widgets/ui_widgets.dart';

class BadgesCard extends StatelessWidget {
  final String subject;
  final String proficiency;
  final String time;
  final String duration;

  const BadgesCard({super.key, required this.subject, required this.proficiency, required this.time, required this.duration});

  @override
  Widget build(BuildContext context) {
    return InkCardShell(
      leftAccent: Colors.orange,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quadratic Equations",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text("Mastered", style: TextStyle(color: Colors.grey.shade600)),
          SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.calendar_month, color: Colors.grey.shade500),
              SizedBox(width: 5),
              Text("Today, 3:00PM", style: TextStyle(color: Colors.grey.shade500),),

              SizedBox(width: 15),
              Icon(Icons.access_time, color: Colors.grey.shade500),
              SizedBox(width: 5),
              Text("20 mins", style: TextStyle(color: Colors.grey.shade500)),
            ],
          ),
        ],
      ),
    );
  }
}
