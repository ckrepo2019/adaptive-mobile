import 'package:flutter/material.dart';
import 'package:flutter_lms/widgets/app_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class MyClassmatesPage extends StatefulWidget {
  const MyClassmatesPage({super.key});

  @override
  State<MyClassmatesPage> createState() => _MyClassmatesPageState();
}

class _MyClassmatesPageState extends State<MyClassmatesPage> {
  late List<Map<String, dynamic>> _all;
  late List<Map<String, dynamic>> _filtered;
  String _q = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map? ?? {};
    final rawList = (args['classmates'] as List?) ?? const [];
    _all = rawList
        .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    _filtered = _all;
  }

  void _applyFilter(String q) {
    setState(() {
      _q = q.trim().toLowerCase();
      if (_q.isEmpty) {
        _filtered = _all;
      } else {
        _filtered = _all.where((m) {
          final fn = (m['firstname'] ?? '').toString().toLowerCase();
          final ln = (m['lastname'] ?? '').toString().toLowerCase();
          final sec = (m['section_name'] ?? '').toString().toLowerCase();
          final lvl = (m['level_name'] ?? '').toString().toLowerCase();
          return fn.contains(_q) ||
              ln.contains(_q) ||
              sec.contains(_q) ||
              lvl.contains(_q);
        }).toList();
      }
    });
  }

  String _fullName(Map m) {
    final f = (m['firstname'] ?? '').toString().trim();
    final l = (m['lastname'] ?? '').toString().trim();
    final name = [f, l].where((s) => s.isNotEmpty).join(' ');
    return name.isEmpty ? '—' : name;
  }

  String _subtitle(Map m) {
    final level = (m['level_name'] ?? '').toString().trim(); // e.g. GRADE 7
    final section = (m['section_name'] ?? '')
        .toString()
        .trim(); // e.g. SECTION A
    if (level.isEmpty && section.isEmpty) return '—';
    if (level.isEmpty) return section;
    if (section.isEmpty) return level;
    return '$level • $section';
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map? ?? {};
    final subjectName = (args['subjectName'] ?? '').toString();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: GlobalAppBar(title: 'My Classmates', showBack: true),
      body: Column(
        children: [
          // Filter chip row
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 6, 16, 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Date Added',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          // List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(30, 6, 16, 16),
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              itemBuilder: (_, i) {
                final m = _filtered[i];
                return _ClassmateTile(
                  name: _fullName(m),
                  subtitle: _subtitle(m),
                  imageUrl: (m['profilepic'] ?? '').toString(),
                  onMessageTap: () {
                    // TODO: navigate to your chat screen, pass IDs you need
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Message ${_fullName(m)}')),
                    );
                  },
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: _filtered.length,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassmateTile extends StatelessWidget {
  const _ClassmateTile({
    required this.name,
    required this.subtitle,
    required this.imageUrl,
    this.onMessageTap,
  });

  final String name;
  final String subtitle;
  final String imageUrl;
  final VoidCallback? onMessageTap;

  bool get _hasImg =>
      imageUrl.trim().isNotEmpty && imageUrl.toLowerCase() != 'null';

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF2ECC71);

    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          // avatar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 56,
              height: 56,
              color: const Color(0xFFEDEDED),
              child: _hasImg
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person,
                        size: 28,
                        color: Colors.black38,
                      ),
                    )
                  : const Icon(Icons.person, size: 28, color: Colors.black38),
            ),
          ),
          const SizedBox(width: 12),

          // name + green dot + subtitle
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // name row with green dot beside it
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.black54,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // trailing: outlined green “message” icon (clickable)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: onMessageTap,
              customBorder: const CircleBorder(),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: green, width: 2),
                  color: Colors.transparent,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 20,
                  color: green,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
