import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_lms/config/routes.dart';
import 'intro_layout.dart';

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({super.key});

  @override
  State<GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage> {
  Map<String, dynamic>? _studentHomeData;
  String? _token, _uid;
  int? _userType;
  bool _printed = false;

  void _logLarge(Object obj, {int chunk = 900}) {
    final s = obj is String
        ? obj
        : const JsonEncoder.withIndent('  ').convert(obj);
    for (var i = 0; i < s.length; i += chunk) {
      debugPrint(s.substring(i, math.min(i + chunk, s.length)));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_printed) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      if (args['studentHomeData'] is Map) {
        _studentHomeData = Map<String, dynamic>.from(
          args['studentHomeData'] as Map,
        );
      }
      _token = args['token'] as String?;
      _uid = args['uid'] as String?;
      _userType = args['userType'] as int?;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_printed) return;
      _printed = true;

      if (_studentHomeData == null) {
        debugPrint('[GetStarted] No studentHomeData in route args. args=$args');
        return;
      }

      final d = _studentHomeData!;
      debugPrint('[GetStarted] keys: ${d.keys.toList()}');
      debugPrint(
        '[GetStarted] enrollment_data: ${jsonEncode(d['enrollment_data'])}',
      );
      debugPrint(
        '[GetStarted] subjects=${(d['subjects'] as List?)?.length ?? 0}, '
        'hobbyTypes=${(d['hobbies_type'] as List?)?.length ?? 0}, '
        'learnersProfile=${(d['learners_profile'] as List?)?.length ?? 0}, '
        'questions=${(d['learner_questions'] as List?)?.length ?? 0}',
      );
      debugPrint('----- GetStarted: full studentHomeData -----');
      _logLarge(d);
      debugPrint('----- end studentHomeData -----');
    });
  }

  @override
  Widget build(BuildContext context) {
    return IntroLayout(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 300,
                    width: 400,
                    child: Image.asset(
                      'assets/images/intro/intro.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AdaptiveHub',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 43,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Welcome to your Adaptive Learning Journey!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.introduction,
                    arguments: {
                      'token': _token,
                      'uid': _uid,
                      'userType': _userType,
                      'studentHomeData': _studentHomeData, // <-- pass it
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF234FF5),
                  elevation: 0,
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Get Started'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
