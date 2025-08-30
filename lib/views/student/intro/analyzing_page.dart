import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_lms/controllers/api_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_lms/views/base_view.dart';
import 'package:flutter_lms/config/routes.dart';
import 'package:flutter_lms/controllers/student/student_home.dart';

class AnalyzingPage extends BaseView {
  const AnalyzingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AnalyzingBody();
  }
}

class _AnalyzingBody extends StatefulWidget {
  const _AnalyzingBody();

  @override
  State<_AnalyzingBody> createState() => _AnalyzingBodyState();
}

class _AnalyzingBodyState extends State<_AnalyzingBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchAndGo());
  }

  Future<void> _fetchAndGo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final args = ModalRoute.of(context)?.settings.arguments;
      int? id;
      if (args is Map && args['studentId'] != null) {
        id = args['studentId'] is int
            ? args['studentId']
            : int.tryParse(args['studentId'].toString());
      }
      id ??= prefs.getInt('id');
      debugPrint('Using studentId: $id');
      if (token == null || id == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Missing session or student ID. Please sign in again.',
            ),
          ),
        );
        return;
      }
      final ApiResponse<List<dynamic>> resp =
          await StudentHomeController.fetchLearnerProfiles(
            token: token,
            studentId: id,
          );
      if (!mounted) return;
      if (resp.success && resp.data != null && resp.data!.isNotEmpty) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.resultLearnerType,
          (route) => false,
          arguments: resp.data,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resp.message ?? 'No learner profile found.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;
    final topInset = mq.padding.top;
    final bottomInset = mq.padding.bottom;
    double clamp(double v, double min, double max) =>
        v < min ? min : (v > max ? max : v);
    final padX = clamp(w * 0.07, 18, 28);
    final overlineSize = clamp(w * 0.038, 12, 16);
    final titleSize = clamp(w * 0.12, 32, 42);
    final textAnchorY = h * 0.58;
    final targetWidth = clamp(w * 1.35, 420, 900);
    final targetHeight = targetWidth * 0.95;
    final overlap = clamp(h * 0.02, 8, 24);
    final bottomPush = (bottomInset + overlap + h * 0.18 + 150);
    final leftOverlap = clamp(w * 0.18, 30, 100);

    return Scaffold(
      backgroundColor: const Color(0xFF0055FF),
      body: RefreshIndicator(
        onRefresh: _fetchAndGo,
        color: Colors.white,
        backgroundColor: const Color(0xFF0055FF),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: constraints.maxHeight,
                width: constraints.maxWidth,
                child: SafeArea(
                  bottom: false,
                  child: Stack(
                    fit: StackFit.expand,
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: padX,
                        right: padX,
                        top: math.max(
                          topInset + 8,
                          textAnchorY - (titleSize * 1.8),
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: w * 0.78),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Let's get to know each other",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.92),
                                  fontSize: overlineSize,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.2,
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Hold On ,\nWe're Analyzing.",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: titleSize,
                                  height: 1.1,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Transform.translate(
                          offset: Offset(-leftOverlap, bottomPush),
                          child: OverflowBox(
                            minWidth: 0,
                            minHeight: 0,
                            maxWidth: targetWidth * 1.1,
                            maxHeight: targetHeight,
                            child: SizedBox(
                              width: targetWidth,
                              height: targetHeight,
                              child: Image.asset(
                                'assets/images/intro/analyzing_model.png',
                                fit: BoxFit.contain,
                                alignment: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
