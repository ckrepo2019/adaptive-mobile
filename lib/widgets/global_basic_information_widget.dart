import 'package:flutter/material.dart';

// not needed, will delete this
class GlobalBasicInformationWidget extends StatelessWidget {
  final String classTitle;
  final String subject;
  final String time;
  final String duration;

  const GlobalBasicInformationWidget({
    super.key,
    required this.classTitle,
    required this.subject,
    required this.time,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Card(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      elevation: 5,
      child: InkWell(
        onTap: () {}, // leaving this empty for now
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
                      classTitle,
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

                    SizedBox(height: screenHeight * 0.04),

                    // ===== Bottom Row (time & duration) =====
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
                          Icons.access_time,
                          color: Colors.grey.shade500,
                          size: screenWidth * 0.045,
                        ),
                        SizedBox(width: screenWidth * 0.015),
                        Text(
                          duration,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: screenWidth * 0.032,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Spacer(flex: 3),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: Colors.grey.shade700,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
