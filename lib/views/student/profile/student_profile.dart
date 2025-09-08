import 'package:Adaptive/controllers/auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Adaptive/widgets/app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Adaptive/controllers/api_response.dart';
import 'package:Adaptive/config/routes.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  double _clamp(double v, double min, double max) =>
      v < min ? min : (v > max ? max : v);

  // ---------- helpers ----------
  Map<String, dynamic> _asMap(dynamic v) =>
      (v is Map) ? Map<String, dynamic>.from(v) : <String, dynamic>{};

  List _asList(dynamic v) => (v is List) ? v : const [];

  String _fullName(Map<String, dynamic> s) {
    final first = (s['firstname'] ?? '').toString().trim();
    final middle = (s['middlename'] ?? '').toString().trim();
    final last = (s['lastname'] ?? '').toString().trim();
    final parts = [first, middle, last].where((p) => p.isNotEmpty).toList();
    return parts.isNotEmpty ? parts.join(' ') : 'Student';
  }

  Future<void> _performLogout(BuildContext context) async {
    void _showLoading() {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
    }

    void _hideLoading() {
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    _showLoading(); // <-- DO NOT await

    try {
      if (token == null || token.isEmpty) {
        await prefs.remove('token');
        await prefs.remove('uid');
        await prefs.remove('id');
        await prefs.remove('user_type');
        _hideLoading();
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.signIn,
            (_) => false,
          );
        }
        return;
      }

      final ApiResponse<void> res = await AuthController.logout(token: token);

      _hideLoading();

      if (res.success) {
        await prefs.remove('token');
        await prefs.remove('uid');
        await prefs.remove('id');
        await prefs.remove('user_type');
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.signIn,
            (_) => false,
          );
        }
      } else {
        final msg = (res.message ?? '').toLowerCase();
        final looksUnauthorized =
            msg.contains('401') ||
            msg.contains('unauth') ||
            msg.contains('invalid');

        if (looksUnauthorized) {
          await prefs.remove('token');
          await prefs.remove('uid');
          await prefs.remove('id');
          await prefs.remove('user_type');
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.signIn,
              (_) => false,
            );
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(res.message ?? 'Logout failed')),
            );
          }
        }
      }
    } catch (e) {
      _hideLoading();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Logout error: $e')));
      }
    }
  }

  /// Collect ALL learner type names (unique, in order)
  List<String> _learnerTypeNames(
    Map<String, dynamic> rootData,
    Map<String, dynamic> student,
  ) {
    final lpRoot = _asList(rootData['learners_profile']);
    final lpStudent = _asList(student['learners_profile']);
    final source = lpRoot.isNotEmpty ? lpRoot : lpStudent;

    final seen = <String>{};
    final result = <String>[];

    for (final item in source) {
      final m = _asMap(item);
      final lt = _asMap(m['learners_types']);
      final name = (lt['name'] ?? '').toString().trim();
      if (name.isNotEmpty && !seen.contains(name.toLowerCase())) {
        seen.add(name.toLowerCase());
        result.add(name);
      }
    }
    return result;
  }

  String _gradeLevel(
    Map<String, dynamic> rootData,
    Map<String, dynamic> student,
  ) {
    final ed = _asMap(rootData['enrollment_data']);
    final ln = (ed['level_name'] ?? '').toString().trim();
    if (ln.isNotEmpty) return ln;
    final ln2 = (student['level_name'] ?? '').toString().trim();
    return ln2.isNotEmpty ? ln2 : 'N/A';
  }

  String _formatBirthdate(String? iso) {
    if (iso == null || iso.trim().isEmpty) return 'N/A';
    try {
      final dt = DateTime.tryParse(iso);
      if (dt == null) return iso;
      const months = [
        '',
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      return '${months[dt.month]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;

    final rawArgs = ModalRoute.of(context)?.settings.arguments;
    final Map<String, dynamic> args = (rawArgs is Map)
        ? Map<String, dynamic>.from(rawArgs)
        : {};
    // shape: { data: { student, learners_profile, enrollment_data, ... } }
    final Map<String, dynamic> rootData = _asMap(args['data']).isNotEmpty
        ? _asMap(args['data'])
        : args;

    final Map<String, dynamic> student = _asMap(rootData['student']);

    final String welcomeName =
        (student['firstname']?.toString().trim().isNotEmpty ?? false)
        ? student['firstname'].toString().trim()
        : 'Student';

    final String fullName = _fullName(student);
    final List<String> learnerTypes = _learnerTypeNames(rootData, student);
    final String gradeLevel = _gradeLevel(rootData, student);
    final String birthdate = _formatBirthdate(
      student['date_of_birth']?.toString(),
    );

    final double padX = _clamp(w * 0.06, 16, 24);
    final double helloSize = _clamp(w * 0.055, 16, 20);
    final double subSize = _clamp(w * 0.030, 12, 50);
    final double headerHeight = _clamp(h * 0.38, 280, 360);
    final double sheetTop = _clamp(h * 0.35, 300, 420);
    final double sheetRadius = 26;
    final double illoW = _clamp(w * 1.210, 380, 600);
    final double illoH = illoW * 0.80;
    final double illoRightBleed = _clamp(w * 0.1, 150, 200);
    final double illoDrop = _clamp(h * 0.10, 40, 80);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const GlobalAppBar(title: 'Profile', showBack: true),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: _clamp(h * 0.18, 140, 220)),
              child: Column(
                children: [
                  SizedBox(
                    height: headerHeight,
                    width: double.infinity,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: padX * 1.3,
                            right: padX * 1.3,
                            top: padX * 2.2,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ---- Welcome text: allow wrapping to next line ----
                              Text(
                                'Welcome $welcomeName.',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: helloSize,
                                  color: Colors.black87,
                                ),
                                softWrap: true,
                                maxLines: 2, // force wrap instead of truncation
                                overflow: TextOverflow.visible,
                              ),
                              const SizedBox(height: 6),

                              // ---- Learner types: wrap multiple types gracefully ----
                              if (learnerTypes.isEmpty)
                                Text(
                                  'Learner Profile',
                                  style: GoogleFonts.poppins(
                                    fontSize: subSize,
                                    color: Colors.black54,
                                  ),
                                  softWrap: true,
                                )
                              else
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: learnerTypes.map((t) {
                                    return Container(
                                      margin: const EdgeInsets.only(
                                        bottom: 6,
                                      ), // spacing between lines
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE3F2FD),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        border: Border.all(
                                          color: const Color(0xFF90CAF9),
                                        ),
                                      ),
                                      child: Text(
                                        '$t Learner',
                                        style: GoogleFonts.poppins(
                                          fontSize: subSize,
                                          color: const Color(0xFF1565C0),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: -illoRightBleed,
                          bottom: -illoDrop,
                          child: SizedBox(
                            width: illoW,
                            height: illoH,
                            child: Image.asset(
                              'assets/images/student-profile/default-female-profile.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: sheetTop,
            bottom: 0,
            child: _ProfileSheet(
              radius: sheetRadius,
              padX: padX,
              name: fullName,
              learnerTypes: learnerTypes, // <- pass list
              gradeLevel: gradeLevel,
              birthdate: birthdate,
              onLogout: () => _performLogout(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSheet extends StatelessWidget {
  const _ProfileSheet({
    required this.radius,
    required this.padX,
    required this.onLogout,
    required this.name,
    required this.learnerTypes, // now a list
    required this.gradeLevel,
    required this.birthdate,
  });

  final double radius;
  final double padX;
  final VoidCallback onLogout;
  final String name;
  final List<String> learnerTypes;
  final String gradeLevel;
  final String birthdate;

  static double _clamp(double v, double min, double max) =>
      v < min ? min : (v > max ? max : v);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Material(
      elevation: 10,
      shadowColor: const Color(0x33000000),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(radius),
        topRight: Radius.circular(radius),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1F5BFF),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(radius),
            topRight: Radius.circular(radius),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  child: Icon(Icons.edit, color: Colors.white),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padX * 1.8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Field(label: 'Name', value: name),

                  // ---- Learner Type(s): wrap to next line(s) if long ----
                  if (learnerTypes.isEmpty)
                    const _Field(label: 'Learner Type', value: '—')
                  else
                    _Field(
                      label: 'Learner Type',
                      // join with comma, let Text wrap
                      value: learnerTypes.join(', '),
                    ),

                  _Field(label: 'Grade Level', value: gradeLevel),
                  _Field(label: 'Birthdate', value: birthdate),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.fromLTRB(padX, 8, padX, 18),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  onPressed: onLogout,
                  child: Text(
                    'Logout',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF1F5BFF),
                      fontWeight: FontWeight.w600,
                      fontSize: _clamp(w * 0.045, 14, 18),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    double clamp(double v, double min, double max) =>
        v < min ? min : (v > max ? max : v);
    final double labelSize = clamp(w * 0.032, 11, 13);
    final double valueSize = clamp(w * 0.045, 15, 18);

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label (small) — wrapping is fine but usually short
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.85),
              fontSize: labelSize,
              fontWeight: FontWeight.w500,
            ),
            softWrap: true,
          ),
          const SizedBox(height: 6),
          // Value (big) — allow wrapping to next line(s)
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: valueSize,
              fontWeight: FontWeight.w700,
            ),
            softWrap: true,
            overflow: TextOverflow.visible, // don't ellipsize; wrap instead
          ),
        ],
      ),
    );
  }
}
