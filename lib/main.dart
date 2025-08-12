import 'package:flutter/material.dart';
import 'package:get/get.dart'; // <-- GetX
import 'package:shared_preferences/shared_preferences.dart';
import 'config/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // <-- use GetMaterialApp
      debugShowCheckedModeBanner: false,
      title: 'Flutter LMS Adaptive',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const _LaunchGate(), // <-- splash/boot gate
      getPages: AppPages.pages, // <-- your GetPage list
      // no initialRoute when using `home`
    );
  }
}

class _LaunchGate extends StatefulWidget {
  const _LaunchGate();

  @override
  State<_LaunchGate> createState() => _LaunchGateState();
}

class _LaunchGateState extends State<_LaunchGate> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token');
    final uid = prefs.getString('uid');
    final userType = prefs.getInt('usertype_ID');
    final id = prefs.getInt('id'); // optional

    if (token != null && uid != null && userType != null) {
      // go straight to get-user with args
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(
          AppRoutes.getUser,
          arguments: {
            'token': token,
            'uid': uid,
            'usertype_ID': userType,
            if (id != null) 'id': id,
          },
        );
      });
    } else {
      // no session -> sign-in
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(AppRoutes.signIn);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
