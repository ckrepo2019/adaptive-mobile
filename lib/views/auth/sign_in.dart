import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_lms/config/routes.dart';
import 'package:flutter_lms/controllers/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _obscurePassword = true;
  bool _loading = false;

  final Color primaryBlue = const Color(0xFF234FF5);
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  double _clamp(double v, double minV, double maxV) =>
      math.max(minV, math.min(maxV, v));

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final resp = await AuthController.login(
      username: _usernameCtrl.text,
      password: _passwordCtrl.text,
    );

    setState(() => _loading = false);

    if (resp.success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', resp.data!['token']);
      await prefs.setInt('id', resp.data!['id']);
      await prefs.setString('uid', resp.data!['uid'].toString());
      await prefs.setInt('usertype_ID', resp.data!['user_type']);

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.getUser,
        arguments: {
          'token': resp.data!['token'],
          'id': resp.data!['id'],
          'uid': resp.data!['uid'].toString(),
          'usertype_ID': resp.data!['user_type'],
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resp.message ?? 'Login failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final sh = mq.size.height;
    final bottomInset = mq.viewInsets.bottom;

    final hPad = _clamp(sw * 0.06, 16, 28);
    final topPad = _clamp(sh * 0.08, 24, 48);
    final gapSm = _clamp(sh * 0.014, 8, 14);
    final gapMd = _clamp(sh * 0.02, 12, 20);
    final fieldHeight = _clamp(sh * 0.065, 46, 56);
    final btnHeight = _clamp(sh * 0.07, 48, 60);
    final titleSize = _clamp(sw * 0.10, 28, 30);
    final welcomeSize = _clamp(sw * 0.042, 14, 18);

    final imgHeight = _clamp(sh * 0.32, 220, 360);
    final reservedBottom = _clamp(imgHeight * 0.30, 52, 120);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              right: 0,
              bottom: -8,
              child: IgnorePointer(
                child: SizedBox(
                  height: imgHeight,
                  child: Image.asset(
                    'assets/images/auth/auth_model.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, c) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      hPad,
                      topPad,
                      hPad,
                      (bottomInset > 0 ? bottomInset : reservedBottom) + 16,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            c.maxHeight -
                            topPad -
                            ((bottomInset > 0 ? bottomInset : reservedBottom) +
                                16),
                        maxWidth: 560,
                      ),
                      child: Center(
                        child: Transform.translate(
                          offset: Offset(0, -_clamp(sh * 0.06, 12, 48)),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome here student!',
                                  style: TextStyle(
                                    fontSize: welcomeSize,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: _clamp(gapSm, 4, 10)),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Sign in to your Account',
                                    style: TextStyle(
                                      fontSize: titleSize,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                SizedBox(height: gapMd),
                                SizedBox(
                                  height: fieldHeight,
                                  child: TextFormField(
                                    controller: _usernameCtrl,
                                    textInputAction: TextInputAction.next,
                                    validator: (v) => v == null || v.isEmpty
                                        ? 'Enter username'
                                        : null,
                                    decoration: InputDecoration(
                                      hintText: 'Username',
                                      suffixIcon: const Icon(
                                        Icons.person,
                                        size: 20,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 16,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: gapSm),
                                SizedBox(
                                  height: fieldHeight,
                                  child: TextFormField(
                                    controller: _passwordCtrl,
                                    obscureText: _obscurePassword,
                                    validator: (v) => v == null || v.isEmpty
                                        ? 'Enter password'
                                        : null,
                                    decoration: InputDecoration(
                                      hintText: 'Password',
                                      suffixIcon: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                              size: 20,
                                            ),
                                            onPressed: () => setState(
                                              () => _obscurePassword =
                                                  !_obscurePassword,
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.only(right: 8),
                                            child: Icon(Icons.lock, size: 20),
                                          ),
                                        ],
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 16,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: gapMd),
                                SizedBox(
                                  width: double.infinity,
                                  height: btnHeight,
                                  child: ElevatedButton(
                                    onPressed: _loading
                                        ? null
                                        : () => _handleSignIn(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryBlue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          _clamp(sw * 0.1, 20, 28),
                                        ),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: _loading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            'Sign In',
                                            style: TextStyle(
                                              fontSize: _clamp(
                                                sw * 0.05,
                                                16,
                                                20,
                                              ),
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
