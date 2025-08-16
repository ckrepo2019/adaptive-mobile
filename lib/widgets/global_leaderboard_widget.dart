import 'package:flutter/material.dart';

class GlobalLeaderboardWidget extends StatelessWidget {
  final String studentName;
  final String badgeTitle;

  const GlobalLeaderboardWidget({
    super.key,
    required this.studentName,
    required this.badgeTitle,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Card(
      color: Colors.white,
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      elevation: 5,
      child: InkWell(
        onTap: () {}, 
        child: Container(
          width: double.infinity,
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
                  horizontal: screenWidth * 0.045,
                  vertical: screenHeight * 0.035,
                ),
                child: Row(
                  children: [
                    Icon(Icons.ac_unit_outlined, color: Colors.blue, size: 55,),
                    SizedBox(width: 10,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          studentName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.06, // responsive title
                          ),
                        ),
                                
                        Text(
                          badgeTitle,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: screenWidth * 0.035,
                            height: 0.7
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
      ),
    );
  }
}
