import 'package:flutter/material.dart';
import 'package:flutter_lms/views/base_view.dart';
import 'package:flutter_lms/widgets/base_widgets.dart';

class ClassProgressWidget extends BaseView {
  const ClassProgressWidget({
    super.key,
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
              width: 5,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.calculate, size: 74, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Math Class 101",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Spacer(),
                        Text("35%")
                      ],
                    ),
                    SizedBox(
                      height: 10,
                      child: SingleDotLinearProgress(progress: .5),
                    ),
                    Text(
                      "14 Chapters · 3 Units",
                      style: TextStyle(color: Colors.grey.shade500),
                    )
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

class SingleDotLinearProgress extends BaseWidget {
  final double progress; // 0.0 to 1.0
  final double height;
  final double dotRadius;
  final Color backgroundColor;
  final Color progressColor;
  final Color dotColor;

  const SingleDotLinearProgress({
    super.key,
    required this.progress,
    this.height = 6.0,
    this.dotRadius = 4.0,
    this.backgroundColor = const Color.fromARGB(255, 237, 150, 150),
    this.progressColor = Colors.red,
    this.dotColor = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth;
        final dotPosition = barWidth * progress;

        return Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Background track
            Container(
              height: height,
              width: barWidth,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
            // Filled progress
            Container(
              height: height,
              width: dotPosition,
              decoration: BoxDecoration(
                color: progressColor,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
            // Dot at the end of progress
            Positioned(
              left: dotPosition - dotRadius,
              child: Container(
                width: dotRadius * 2,
                height: dotRadius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
