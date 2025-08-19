import 'package:flutter/material.dart';
import 'package:flutter_lms/config/routes.dart';
import 'package:flutter_lms/controllers/get_user.dart';
import 'package:flutter_lms/controllers/api_response.dart';
import 'package:get/get.dart';

class GetUserPage extends StatefulWidget {
  const GetUserPage({super.key});

  @override
  State<GetUserPage> createState() => _GetUserPageState();
}

class _GetUserPageState extends State<GetUserPage> {
  bool _loading = true;
  String? _error;

  Map<String, dynamic>? _user;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Expecting: { token:String, id:int, usertype_ID:int }
    final argsRaw = ModalRoute.of(context)?.settings.arguments;
    if (argsRaw is! Map) {
      setState(() {
        _loading = false;
        _error = 'Missing arguments.';
      });
      return;
    }

    final token = argsRaw['token'] as String?;
    final uid = argsRaw['uid'] as String?;
    final userType = argsRaw['usertype_ID'] as int?;

    if (token == null || uid == null || userType == null) {
      setState(() {
        _loading = false;
        _error = 'Invalid arguments received.';
      });
      return;
    }

    _load(token, uid, userType);
  }

  Future<void> _load(String token, String uid, int userType) async {
    final ApiResponse<Map<String, dynamic>> resp = await UserController.getUser(
      token: token,
      uid: uid,
      userType: userType,
    );

    if (!mounted) return;

    if (resp.success && resp.data != null) {
      _user = resp.data;

      // Redirect based on userType
      switch (userType) {
        case 4: // student
          Get.toNamed(
            AppRoutes.studentShell,
            arguments: {'token': token, 'uid': uid, 'userType': 4},
          );
          break;
        case 5: // teacher
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.teacherHome, // or teacher/collaborator
            (route) => false, // remove all previous routes
            arguments: {
              'token': token,
              'uid': uid,
              'userType': 5,
            }, // pass your args
          );
          break;
        case 6: // collaborator (adjust to your mapping)
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.collaboratorHome, // or teacher/collaborator
            (route) => false, // remove all previous routes
            arguments: {
              'token': token,
              'uid': uid,
              'userType': 6,
            }, // pass your args
          );
          break;
        default:
          // Fallback if unknown type
          setState(() {
            _loading = false;
            _error = 'Unknown user type: $userType';
          });
      }
    } else {
      setState(() {
        _loading = false;
        _error = resp.message ?? 'Failed to fetch user.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Text(_error!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    // Shouldn’t be seen—redirect happens on success.
    return const Scaffold(body: SizedBox.shrink());
  }
}
