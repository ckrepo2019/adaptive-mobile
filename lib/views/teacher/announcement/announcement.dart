import 'package:flutter/material.dart';
import 'package:Adaptive/views/teacher/teacher_global_layout.dart';
import 'package:Adaptive/widgets/app_bar.dart';
import 'package:Adaptive/widgets/global_announcement_card.dart';
import 'package:Adaptive/widgets/global_chip.dart';

class AnnouncementsPage extends StatelessWidget {
  const AnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: GlobalAppBar(title: 'Announcements', showBack: true),
      body: TeacherGlobalLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 25),

            Row(
              children: [
                CustomChip(
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  borderColor: Colors.transparent,
                  chipTitle: 'Date Added',
                  iconData: Icons.access_time,
                ),
                SizedBox(width: 5),
                CustomChip(
                  backgroundColor: Colors.transparent,
                  textColor: Colors.grey.shade500,
                  borderColor: Colors.black54,
                  chipTitle: 'Events',
                  iconData: Icons.event,
                ),
              ],
            ),

            SizedBox(height: 15),

            GlobalAnnouncementCard(
              title: 'Enrollment is Now Open!',
              subtitle: 'Posted by Celine',
              delegations: 'To all Students',
            ),
            SizedBox(height: 10),
            GlobalAnnouncementCard(
              title: 'Enrollment is Now Open!',
              subtitle: 'Posted by Celine',
              delegations: 'To all Students',
            ),
          ],
        ),
      ),
    );
  }
}
