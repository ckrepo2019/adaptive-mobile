import 'package:flutter/material.dart';
import 'package:flutter_lms/views/teacher/teacher_global_layout.dart';
import 'package:flutter_lms/widgets/app_bar.dart';
import 'package:flutter_lms/widgets/global_books_widget.dart';
import 'package:flutter_lms/widgets/global_chip.dart';
import 'package:flutter_lms/widgets/global_subject_widget.dart';

class AssignedBooksPage extends StatelessWidget {
  const AssignedBooksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GlobalAppBar(
        title: 'Books Assigned',
        showBack: true,
        showNotifications: false,
        showProfile: false,
      ),
      body: TeacherGlobalLayout(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            children: [
              // Chips row — separated with spacing, horizontally scrollable if overflow
              Row(
                children: [
                  CustomChip(
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    borderColor: Colors.transparent,
                    chipTitle: 'Date Added',
                    iconData: Icons.access_time,
                  ),
                  const SizedBox(width: 8),
                  CustomChip(
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    borderColor: Colors.grey.shade500,
                    chipTitle: 'Most Recent',
                    iconData: Icons.update,
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.search),
                    tooltip: 'Search books',
                  ),
                ],
              ),
              

              const SizedBox(height: 12),

              // Scrollable content list
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return const GlobalBooksWidget(
                      grade_level: 'Grade 6',
                      totalSections: '3',
                      dateAssined: 'August 27, 2025',
                      subject: 'Essential Algebra for Beginners',
                      imageUrl: '',
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
