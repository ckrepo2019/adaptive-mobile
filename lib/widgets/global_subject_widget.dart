import 'package:flutter_lms/widgets/base_widgets.dart';
import 'package:flutter/material.dart';

class GlobalSubjectWidget extends BaseWidget {
  final String classCode;
  final String subject;
  final String time;
  final String teacherName;

  const GlobalSubjectWidget({
    super.key,
    required this.classCode, required this.time, required this.teacherName, required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 15),
      elevation: 5,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: const Border(left: BorderSide(color: Colors.yellow, width: 2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              child: Image.network(
                'https://qph.cf2.quoracdn.net/main-qimg-5d31a74a0fdc2489c87a65bb61d39507.webp',
                fit: BoxFit.cover,
                height: 100,
                width: double.infinity,
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classCode,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(subject, style: TextStyle(
                    color: Colors.grey.shade500
                  ),),
              
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_month, color: Colors.grey.shade500),
                          const SizedBox(width: 5),
                          Text(
                            "Today, $time",
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                          ),
                          const SizedBox(width: 20),
                          Icon(Icons.person, color: Colors.grey.shade500),
                          Text(
                            teacherName,
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
