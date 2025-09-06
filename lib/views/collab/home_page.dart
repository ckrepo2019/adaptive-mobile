import 'package:flutter/material.dart';
import 'package:Adaptive/controllers/get_user.dart';
import 'package:Adaptive/controllers/api_response.dart';

class CollaboratorHomePage extends StatefulWidget {
  const CollaboratorHomePage({super.key});

  @override
  State<CollaboratorHomePage> createState() => _CollaboratorHomePageState();
}

class _CollaboratorHomePageState extends State<CollaboratorHomePage> {
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
          width: 140,
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
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Collaborator Home')),
        body: Center(
          child: Text(_error!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }
    final c = _user!;
    return Scaffold(
      appBar: AppBar(title: const Text('Collaborator Home')),
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
                  _row('Firstname', c['firstname']),
                  _row('Middlename', c['middlename']),
                  _row('Lastname', c['lastname']),
                  _row('CID', c['cid']),
                  _row('Age', c['age']),
                  _row('Gender', c['gender']),
                  _row('Contact No.', c['contactnumber']),
                  _row('Email', c['emailaddress']),
                  _row('Address', c['address']),
                  _row('Date of Birth', c['date_of_birth']),
                  _row('Is Deleted', c['is_deleted']),
                  _row('Created At', c['created_at']),
                  _row('Updated At', c['updated_at']),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
