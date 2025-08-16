import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class StudentGlobalLayout extends StatelessWidget {
  final bool showBack;
  final Widget child;
  final Color backgroundColor;

  const StudentGlobalLayout(this.showBack, {super.key, required this.child, required this.backgroundColor, });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        leading: showBack
          ? Padding(
            padding: const EdgeInsets.all(15.0),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
              onPressed: () => Get.back(),
            ),
          )
          : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: SafeArea(child: child),
      ),
    );
  }
}
