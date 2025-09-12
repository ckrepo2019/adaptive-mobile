import 'package:Adaptive/views/student/profile/student_profile.dart';
import 'package:Adaptive/views/teacher/notifications/teacher_notifications.dart';
import 'package:flutter/material.dart';
import 'package:Adaptive/config/routes.dart';
import 'package:Adaptive/controllers/get_user.dart';
import 'package:Adaptive/controllers/api_response.dart';
import 'package:Adaptive/controllers/teacher/teacher_schedule_controller.dart';
import 'package:Adaptive/views/student/home/quick_actions.dart';
import 'package:Adaptive/views/teacher/teacher_global_layout.dart';
import 'package:Adaptive/views/teacher/widgets/class_timeline.dart';
import 'package:Adaptive/widgets/app_bar.dart';
import 'package:Adaptive/widgets/global_chip.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class TeacherHomePage extends StatefulWidget {
  final String token;
  final String uid;
  final int userType;

  const TeacherHomePage({
    super.key,
    required this.token,
    required this.uid,
    required this.userType,
  });

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _user;

  List<Map<String, dynamic>> _todayClasses = [];
  bool _loadingSchedule = true;

  @override
  void initState() {
    super.initState();
    _load(widget.token, widget.uid, widget.userType);
  }

  Future<void> _loadSchedule() async {
    setState(() => _loadingSchedule = true);
    final resp = await TeacherScheduleController.fetchTodaySchedule();
    if (!mounted) return;
    if (resp.success) {
      setState(() {
        _todayClasses = resp.data?['classes'] ?? [];
        _loadingSchedule = false;
      });
    } else {
      setState(() {
        _todayClasses = [];
        _loadingSchedule = false;
      });
      debugPrint('❌ Schedule fetch failed: ${resp.message}');
    }
  }

  Future<void> _load(String token, String uid, int type) async {
    setState(() {
      _loading = true;
      _error = null;
    });

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
      await _loadSchedule();
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
      return Scaffold(
        appBar: GlobalAppBar(
          title: 'Home',
          onProfileTap: () {
            Get.toNamed(AppRoutes.profilePage);
          },
        ),
        body: Center(child: CircularProgressIndicator()),
      );
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
    final userType = user['userType'] as int? ?? widget.userType;

    String role;
    switch (userType) {
      case 5:
      case 3:
      case 4:
        role = "Teacher";
        break;
      default:
        role = "User";
    }

    return Scaffold(
      appBar: const GlobalAppBar(title: 'Home'),
      body: TeacherGlobalLayout(
        child: RefreshIndicator(
          onRefresh: () => _load(widget.token, widget.uid, widget.userType),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WelcomeWidget(
                  firstname: user['firstname'] ?? '',
                  lastname: user['lastname'] ?? '',
                  role: role,
                  studentsCount: "30", // TODO: bind actual count
                  section: "Grade 1 : Joy Adviser", // TODO: bind actual section
                ),
                const SizedBox(height: 25),

                // Quick Actions
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
                      onTap: () => Get.toNamed(AppRoutes.teacherSections),
                    ),
                    QuickActionTile(
                      iconAsset:
                          'assets/images/student-home/leaderboards-quickactions.png',
                      label: 'Announcements',
                      onTap: () => Get.toNamed(AppRoutes.announcement),
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
                      onTap: () {
                        Get.toNamed(AppRoutes.profilePage);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // Today's Classes header
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
                      chipTitle: '${_todayClasses.length} Classes',
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                if (_loadingSchedule)
                  const Center(child: CircularProgressIndicator())
                else if (_todayClasses.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No classes scheduled for today.'),
                  )
                else
                  Column(
                    children: _todayClasses.map((c) {
                      final time = c['start_time'] ?? '--:--';
                      final subject = c['subject_name'] ?? 'Unknown';
                      final section = c['section_name'] ?? '';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ClassTimeline(
                          time: time,
                          title: subject,
                          subtitle: section,
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
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

          // Chips
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
