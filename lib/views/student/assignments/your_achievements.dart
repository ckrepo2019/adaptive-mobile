import 'package:flutter/material.dart';
import 'package:flutter_lms/widgets/app_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class YourAchievementsPage extends StatelessWidget {
  const YourAchievementsPage({
    super.key,
    this.items = const [
      _AchItem('🏆', 'Consistency Champ'),
      _AchItem('💡', 'Critical Thinker'),
      _AchItem('🧠', 'Resilient Learner'),
      _AchItem('🔥', 'Streak Star'),
      _AchItem('🔍', 'Visual Voyager'),
    ],
    this.onBack,
    this.onContinue,
  });

  final List<_AchItem> items;
  final VoidCallback? onBack;
  final VoidCallback? onContinue;

  static const Color kBgTop = Color(0xFF2F6BFF);
  static const Color kBgBottom = Color(0xFF1537B9);
  static const Color kTile = Color(0xFF1E3A8A);
  static const Color kTileShadow = Color(0x26122B6B);
  static const double kRadius = 18;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalAppBar(
        title: 'Your Achievements',
        showBack: true,
        showNotifications: false,
        showProfile: false,
        backgroundColor: kBgTop,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [kBgTop, kBgBottom],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 100),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (_, i) => _AchievementTile(item: items[i]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: onContinue ?? () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27),
                        ),
                      ),
                      child: Text(
                        'Continue',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF2563EB),
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.item});
  final _AchItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: Color(0xFF142979).withOpacity(0.37),
        borderRadius: BorderRadius.circular(YourAchievementsPage.kRadius),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(37, 11, 39, 110),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(item.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              item.title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchItem {
  final String emoji;
  final String title;
  const _AchItem(this.emoji, this.title);
}
