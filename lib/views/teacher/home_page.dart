import 'package:flutter/material.dart';
import 'package:flutter_lms/controllers/get_user.dart';
import 'package:flutter_lms/controllers/api_response.dart';
import 'package:flutter_lms/widgets/skeleton_loader.dart';

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
        ),
      ],
    ),
  );

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
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _row('SY ID', t['syID']),
                  _row('Sem ID', t['semID']),
                  _row('Academic Prog ID', t['academicprogID']),
                  _row('Firstname', t['firstname']),
                  _row('Middlename', t['middlename']),
                  _row('Lastname', t['lastname']),
                  _row('TID', t['tid']),
                  _row('Age', t['age']),
                  _row('Gender', t['gender']),
                  _row('Contact No.', t['contactnumber']),
                  _row('Is Active', t['is_active']),
                  _row('Email', t['emailaddress']),
                  _row('Date of Birth', t['date_of_birth']),
                  _row('Street', t['street']),
                  _row('Barangay', t['barangay']),
                  _row('City', t['city']),
                  _row('Province', t['province']),
                  _row('Zip', t['zipcode']),
                  _row('Country', t['country']),
                  _row('Created At', t['created_at']),
                  _row('Updated At', t['updated_at']),
                  _row('leanersprofile', t['lea']),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
