import 'package:flutter/material.dart';
import 'package:flutter_lms/views/utilities/calendar_page.dart';
import 'package:flutter_lms/views/utilities/leaderboard_page.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/routes.dart';
import 'package:flutter_lms/state/bindings/student/student_home_bindings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // safe for async init later
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter LMS Adaptive',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialBinding: StudentHomeBindings(),
      // home: const _LaunchGate(),
      home: LeaderboardPage(),
      getPages: AppPages.pages,
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
    final id = prefs.getInt('id');

    if (token != null && uid != null && userType != null) {
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
