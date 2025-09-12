import 'package:flutter/material.dart';
import 'package:Adaptive/views/teacher/teacher_global_layout.dart';
import 'package:Adaptive/widgets/app_bar.dart';
import 'package:Adaptive/widgets/global_announcement_card.dart';
import 'package:Adaptive/widgets/global_chip.dart';

class AnnouncementsPage extends StatelessWidget {
  const AnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final announcements = [
      {
        'title': 'Enrollment is Now Open!',
        'subtitle': 'Posted by Celine',
        'delegations': 'To all Students',
      },
      {
        'title': 'Orientation Scheduled for Monday',
        'subtitle': 'Posted by Admin',
        'delegations': 'To all Teachers',
      },
      {
        'title': 'System Maintenance Tonight',
        'subtitle': 'Posted by IT',
        'delegations': 'To all Users',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const GlobalAppBar(
        title: 'Announcements',
        showBack: true,
      ),
      body: SafeArea(
        child: TeacherGlobalLayout(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),

              /// Filter chips
              Row(
                children: [
                  const CustomChip(
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    borderColor: Colors.transparent,
                    chipTitle: 'Date Added',
                    iconData: Icons.access_time,
                  ),
                  const SizedBox(width: 5),
                  CustomChip(
                    backgroundColor: Colors.transparent,
                    textColor: Colors.grey.shade500,
                    borderColor: Colors.black54,
                    chipTitle: 'Events',
                    iconData: Icons.event,
                  ),
                ],
              ),
              const SizedBox(height: 15),

              /// Announcements list
              Expanded(
                child: ListView.separated(
                  itemCount: announcements.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = announcements[index];
                    return GlobalAnnouncementCard(
                      title: item['title']!,
                      subtitle: item['subtitle']!,
                      delegations: item['delegations']!,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
