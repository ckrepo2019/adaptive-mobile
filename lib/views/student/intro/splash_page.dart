import 'package:flutter/material.dart';
import 'package:flutter_lms/views/base_view.dart';

class SplashPage extends BaseView {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint("SplashPage initialized ${controller.initialized}");
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.white,
          child: Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FlutterLogo(),
                Text(
                  "XXX",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
