import 'package:flutter/material.dart';
import 'package:flutter_lms/controllers/get_user.dart';
import 'package:flutter_lms/controllers/api_response.dart';
import 'package:flutter_lms/widgets/skeleton_loader.dart';

class TeacherHomePage extends StatelessWidget {
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
    final userType = (args['userType'] as int?) ?? 4;
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

  Widget _row(String label, dynamic value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 160,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value?.toString() ?? '—',
            style: const TextStyle(fontWeight: FontWeight.w500),
            softWrap: true,
          ),

          SizedBox(height: 25,),

          ClassTimeline(),
          ClassTimeline(),


            
          ],
        ),
      ),
    );
  }
}

class WelcomeWidget extends StatelessWidget {
  const WelcomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Teacher Home')),
        body: Center(
          child: Text(_error!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    return SkeletonLoader(isLoading: _loading, child: _buildContent());
  }

  Widget _buildContent() {
    final t = _user!;
    return Scaffold(
      appBar: AppBar(title: const Text('Teacher Home')),
      body: ListView(
        padding: const EdgeInsets.all(16),
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
                children: const [
                  Text(
                    'Welcome Celine.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  Text('Teacher'),
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
                chipTitle: '30 Students',
                iconData: Icons.person,
              ),
              const SizedBox(width: 5),
              CustomChip(
                backgroundColor: Colors.lightBlueAccent.shade100,
                textColor: Colors.blue.shade800,
                borderColor: Colors.transparent,
                chipTitle: 'Grade 1 : Joy Adviser',
                iconData: Icons.class_,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
