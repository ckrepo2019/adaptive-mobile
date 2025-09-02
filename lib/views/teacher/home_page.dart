import 'package:flutter/material.dart';
import 'package:flutter_lms/config/routes.dart';
import 'package:flutter_lms/controllers/get_user.dart';
import 'package:flutter_lms/controllers/api_response.dart';
import 'package:flutter_lms/views/student/home/quick_actions.dart';
import 'package:flutter_lms/views/teacher/widgets/class_timeline.dart';
import 'package:flutter_lms/views/utilities/layouts/global_layout.dart';
import 'package:flutter_lms/widgets/app_bar.dart';
import 'package:flutter_lms/widgets/global_chip.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({super.key});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _user;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! Map) {
      setState(() {
        _loading = false;
        _error = 'Missing route arguments.';
      });
      return;
    }
    final token = args['token'] as String?;
    final uid = args['uid'] as String?;
    final userType = (args['userType'] as int?) ?? 4; // default: student
    if (token == null || uid == null) {
      setState(() {
        _loading = false;
        _error = 'Invalid route arguments.';
      });
      return;
    }
    _load(token, uid, userType);
  }

  Future<void> _load(String token, String uid, int type) async {
    final ApiResponse<Map<String, dynamic>> resp = await UserController.getUser(
      token: token,
      uid: uid,
      userType: type,
    );

    if (!mounted) return;
    if (resp.success) {
      setState(() {
        _user = resp.data!;
        _loading = false;
      });
    } else {
      setState(() {
        _error = resp.message ?? 'Failed to load user.';
        _loading = false;
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
        appBar: const GlobalAppBar(title: 'Home'),
        body: Center(
          child: Text(_error!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    final user = _user!;
    final userType = user['userType'] as int? ?? 4;

    String role;
    switch (userType) {
      case 4: // Example: 3 = Teacher
        role = "Teacher";
        break;
      case 3: // Example: 4 = Student
        role = "Student";
        break;
      default:
        role = "User";
    }

    return Scaffold(
      appBar: const GlobalAppBar(title: 'Home'),
      body: StudentGlobalLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WelcomeWidget(
              firstname: user['firstname'] ?? '',
              lastname: user['lastname'] ?? '',
              role: role,
              studentsCount: "30",
              section: "Grade 1 : Joy Adviser",
            ),
            const SizedBox(height: 25),

            // Quick Actions header
            Row(
              children: [
                const Icon(Icons.open_in_new),
                const SizedBox(width: 10),
                Text(
                  "Quick Actions",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                QuickActionTile(
                  iconAsset:
                      'assets/images/student-home/classes-quickactions.png',
                  label: 'My Classes',
                  onTap: () {
                    Get.toNamed(AppRoutes.subjectClassPage);
                  },
                ),
                QuickActionTile(
                  iconAsset:
                      'assets/images/student-home/leaderboards-quickactions.png',
                  label: 'Announcements',
                  onTap: () {
                    Get.toNamed(AppRoutes.announcement);
                  },
                ),
                QuickActionTile(
                  iconAsset:
                      'assets/images/student-home/leaderboards-quickactions.png',
                  label: 'Leaderboards',
                  onTap: () {},
                ),
                QuickActionTile(
                  iconAsset:
                      'assets/images/student-home/leaderboards-quickactions.png',
                  label: 'Profile',
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 25),

            Row(
              children: [
                const Icon(Icons.book),
                const SizedBox(width: 5),
                const Text("Today's Classes"),
                const Spacer(),
                CustomChip(
                  backgroundColor: Colors.blue.shade100,
                  textColor: Colors.blue.shade500,
                  borderColor: Colors.transparent,
                  chipTitle: '4 Classes', // TODO: replace with API
                ),
              ],
            ),

            const SizedBox(height: 25),
            const ClassTimeline(),
            const ClassTimeline(),
          ],
        ),
      ),
    );
  }
}

class WelcomeWidget extends StatelessWidget {
  final String firstname;
  final String lastname;
  final String role;
  final String studentsCount;
  final String section;

  const WelcomeWidget({
    super.key,
    required this.firstname,
    required this.lastname,
    required this.role,
    required this.studentsCount,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + Name
          Row(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFFF1F3F6),
                backgroundImage: AssetImage(
                  'assets/images/student-home/default-avatar-female.png',
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome $firstname.',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  Text(role),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Chips row
          Row(
            children: [
              CustomChip(
                backgroundColor: Colors.grey,
                textColor: Colors.white,
                borderColor: Colors.transparent,
                chipTitle: '$studentsCount Students',
                iconData: Icons.person,
              ),
              const SizedBox(width: 5),
              CustomChip(
                backgroundColor: Colors.lightBlueAccent,
                textColor: Colors.blue.shade800,
                borderColor: Colors.transparent,
                chipTitle: section,
                iconData: Icons.class_,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
