import 'package:flutter/material.dart';
import 'package:flutter_lms/views/base_view.dart';

class AnalyzingPage extends BaseView {
  const AnalyzingPage({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("AnalyzingPage initialized: ${controller.hashCode}");

    return Scaffold(
      backgroundColor: const Color(0xFF0055FF),
      body: Stack(
        children: [
          // Texts at center left
          SizedBox.expand(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Let's get to know each other",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Hold On ,\nWe're Analyzing.",
                      style: TextStyle(color: Colors.white, fontSize: 40),
                    ),
                    SizedBox(height: 150),
                  ],
                ),
              ),
            ),
          ),

          // Image at bottom left
          Positioned(
            bottom: 0,
            left: 0,
            child: Image.asset(
              'assets/adaptiveLogo.png',
              height: 400,
              width: 400,
            ),
          ),
        ],
      ),
    );
  }
}
