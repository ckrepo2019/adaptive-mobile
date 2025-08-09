import 'package:flutter/material.dart';
import 'package:flutter_lms/config/routes.dart';
import 'package:flutter_lms/views/base_view.dart';

class ResultPage extends BaseView {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image (fills the screen)
          Positioned(
            top: 30,
            left: 0,
            child: Image.asset(
              'assets/tired.png',
              height: 400,
              width: 400,
              // fit: BoxFit.cover,
            ),
          ),

          // Bottom Container
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 400,
              decoration: const BoxDecoration(
                color: Color(0xFF0055FF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "You are a",
                      style: TextStyle(color: Colors.grey.shade200),
                    ),
                    const Row(
                      children: [
                        Text(
                          "Visual Learner",
                          style: TextStyle(color: Colors.white, fontSize: 40),
                        ),
                        SizedBox(width: 10),
                        Icon(
                          Icons.remove_red_eye_outlined,
                          size: 40,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    Text(
                      'Congratulations on completing your\nassessment! Your results indicate that you are\na Visual Learner.',
                      style: TextStyle(
                        color: Colors.grey.shade200,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'We\'ll Customize the content to fit your learning\nstyle, ensuring you have the best experience\npossible.',
                      style: TextStyle(
                        color: Colors.grey.shade200,
                        fontSize: 14,
                        fontWeight: FontWeight.w400, // Regular weight
                      ),
                    ),
                    Spacer(),

                    InkWell(
                      onTap: () => Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.analyzing,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        height: 50,
                        width: double.infinity,
                        padding: EdgeInsets.all(10),
                        child: Center(
                          child: Text(
                            "Get Started",
                            style: TextStyle(
                              color: Colors.blue.shade500,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
