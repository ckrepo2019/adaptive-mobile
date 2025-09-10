import 'package:flutter/material.dart';
import 'package:Adaptive/config/routes.dart';
import 'package:Adaptive/controllers/get_user.dart';
import 'package:Adaptive/controllers/api_response.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

      switch (userType) {
        case 4:
          Get.toNamed(
            AppRoutes.studentShell,
            arguments: {'token': token, 'uid': uid, 'userType': 4},
          );
          break;
        case 5:
          Get.toNamed(
            AppRoutes.teacherShell,
            arguments: {'token': token, 'uid': uid, 'userType': 5},
          );
          break;
        case 6:
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.collaboratorHome,
            (route) => false,
            arguments: {'token': token, 'uid': uid, 'userType': 6},
          );
          break;
        default:
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

      // If authentication failed, clear stored credentials and go to sign in
      if (resp.message?.toLowerCase().contains('unauthenticated') == true ||
          resp.message?.toLowerCase().contains('unauthorized') == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        await prefs.remove('uid');
        await prefs.remove('usertype_ID');
        await prefs.remove('id');

        if (mounted) {
          Get.offAllNamed(AppRoutes.signIn);
        }
      }
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

    return const Scaffold(body: SizedBox.shrink());
  }
}
