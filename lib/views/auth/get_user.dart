import 'package:flutter/material.dart';
import '../../controllers/get_user.dart';
import '../../config/routes.dart';

class GetUserPage extends StatefulWidget {
  const GetUserPage({super.key});

  @override
  State<GetUserPage> createState() => _GetUserPageState();
}

class _GetUserPageState extends State<GetUserPage> {
  Map<String, dynamic>? user;
  String? error;
  bool loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    _load(
      args['token'] as String,
      args['id'] as int,
      args['usertype_ID'] as int,
    );
  }

  Future<void> _load(String token, int id, int type) async {
    final resp = await UserController.getUser(
      token: token,
      id: id,
      userType: type,
    );
    setState(() => loading = false);

    if (resp.success) {
      setState(() => user = resp.data!);

      // Redirect based on userType
      if (type == 4) {
        Navigator.pushReplacementNamed(context, '/student-home');
      } else if (type == 5) {
        Navigator.pushReplacementNamed(context, '/teacher-home');
      } else if (type == 6) {
        Navigator.pushReplacementNamed(context, '/collaborator-home');
      }
    } else {
      setState(() => error = resp.message ?? 'Failed to fetch user');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
              child: Text(error!, style: const TextStyle(color: Colors.red)),
            )
          : const SizedBox.shrink(), // will not display, as we redirect
    );
  }
}
