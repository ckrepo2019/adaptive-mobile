import 'package:flutter/material.dart';
import 'package:flutter_lms/widgets/base_widgets.dart';

class CardWidget extends BaseWidget {
  final String subject;
  final String duration;
  final String title;
  final String deadline;

  const CardWidget({
    super.key,
    required this.subject,
    required this.duration,
    required this.title, required this.deadline,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: const Border(
            left: BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(subject),
              const SizedBox(height: 20),
              Row(
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_month, color: Colors.grey.shade500),
                      const SizedBox(width: 5),
                      Text(
                        "Today, $deadline",
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                      const SizedBox(width: 20),
                      Icon(Icons.av_timer_rounded, color: Colors.grey.shade500),
                      Text(
                        duration,
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                  const Spacer(), 
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
