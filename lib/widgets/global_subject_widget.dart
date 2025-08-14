import 'package:flutter_lms/widgets/base_widgets.dart';
import 'package:flutter/material.dart';

class GlobalSubjectWidget extends BaseWidget {
  final String classCode;
  final String subject;
  final String time;
  final String teacherName;

  const GlobalSubjectWidget({
    super.key,
    required this.classCode,
    required this.time,
    required this.teacherName,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Card(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      elevation: 5,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(screenWidth * 0.02),
          border: Border(
            left: BorderSide(
              color: Colors.yellow,
              width: screenWidth * 0.005,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Top Image =====
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(screenWidth * 0.025),
                topRight: Radius.circular(screenWidth * 0.025),
              ),
              child: Image.network(
                'https://qph.cf2.quoracdn.net/main-qimg-5d31a74a0fdc2489c87a65bb61d39507.webp',
                fit: BoxFit.cover,
                height: screenHeight * 0.15, // responsive image height
                width: double.infinity,
              ),
            ),

            // ===== Text Section =====
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.025,
                vertical: screenHeight * 0.015,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Class code
                  Text(
                    classCode,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.045, // responsive title
                    ),
                  ),

                  // Subject name
                  Text(
                    subject,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: screenWidth * 0.04,
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // ===== Bottom Row (time & teacher) =====
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        color: Colors.grey.shade500,
                        size: screenWidth * 0.045,
                      ),
                      SizedBox(width: screenWidth * 0.015),
                      Text(
                        "Today, $time",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: screenWidth * 0.032,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.05),
                      Icon(
                        Icons.person,
                        color: Colors.grey.shade500,
                        size: screenWidth * 0.045,
                      ),
                      SizedBox(width: screenWidth * 0.015),
                      Flexible(
                        child: Text(
                          teacherName,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: screenWidth * 0.032,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
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
