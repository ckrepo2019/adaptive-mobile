import 'package:flutter/material.dart';
import 'package:Adaptive/widgets/global_basic_information_widget.dart';
// import 'package:Adaptive/widgets/app_bar.dart'; // If you want to swap in your GlobalAppBar

class BookDetailsPage extends StatelessWidget {
  const BookDetailsPage({
    super.key,
    this.title = 'Essential Algebra for Beginners',
    this.subtitle = 'Book Details',
    this.author = 'Robert U. Fox',
    this.assignedSince = 'Feb 18, 2025',
    this.coverUrl,
  });

  final String title;
  final String subtitle;
  final String author;
  final String assignedSince;
  final String? coverUrl;

  static const _brandBlue = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        // If you want to use your GlobalAppBar, replace this AppBar with GlobalAppBar:
        // appBar: GlobalAppBar(
        //   title: 'Book Details',
        //   showBack: true,
        //   showNotifications: false,
        //   showProfile: false,
        //   backgroundColor: _brandBlue,
        // ),
        appBar: AppBar(
          backgroundColor: _brandBlue,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Book Details',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              Text(
                title,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFFF3F4F6),
        body: Stack(
          children: [
            // Blue curved header shape
            Container(
              height: 180,
              decoration: const BoxDecoration(
                color: _brandBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
            ),
            // Main scrollable content
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                children: [
                  // Floating cover card
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.12),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: coverUrl == null || coverUrl!.isEmpty
                              ? _PlaceholderCover()
                              : Image.network(coverUrl!, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // White content card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.06),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title & author
                          Text(
                            title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: .2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                author,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.black.withOpacity(.7),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.verified, color: _brandBlue, size: 16),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Tabs
                          TabBar(
                            labelColor: _brandBlue,
                            unselectedLabelColor: Colors.black54,
                            labelStyle: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                            unselectedLabelStyle: theme.textTheme.bodyMedium,
                            indicatorColor: _brandBlue,
                            tabs: const [
                              Tab(text: 'About Book'),
                              Tab(text: 'Assigned to'),
                              Tab(text: 'Learners'),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Tab content (fixed height to let page scroll)
                          SizedBox(
                            height: 520, // tune height as needed
                            child: TabBarView(
                              children: [
                                _AboutBookTab(assignedSince: assignedSince),
                                _AssignedToTab(),
                                _LearnersTab(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Bottom actions
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _brandBlue,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {},
                          child: Text('Manage Book', style: TextStyle(color: Colors.white),),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            side: BorderSide(color: Colors.red.shade500),
                          ),
                          onPressed: () {},
                          icon: Icon(Icons.block, color: Colors.white, size: 18),
                          label: Text('Unassign Book',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderCover extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFEDD5),
      child: Center(
        child: Text(
          'Cover',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFFFB923C),
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

class _AboutBookTab extends StatelessWidget {
  const _AboutBookTab({required this.assignedSince});
  final String assignedSince;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grey = theme.textTheme.bodySmall?.copyWith(color: Colors.black54);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('About'),
          const SizedBox(height: 6),
          Text(
            'Essential Algebra for Beginners',
            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          _MutedRow('Assigned to you since $assignedSince'),
          const SizedBox(height: 14),
          _SectionTitle('Description'),
          const SizedBox(height: 6),
          Text(
            "Start your algebra journey with confidence! This book introduces the core concepts of algebra in a clear, step-by-step way—perfect for students who are just getting started. Learn how to work with variables, simplify expressions, solve equations, and apply algebra in real-life situations.",
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _ChipPill('Beginner-friendly'),
              _ChipPill('Step-by-step'),
              _ChipPill('Practice Included'),
            ],
          ),
        ],
      ),
    );
  }
}

class _AssignedToTab extends StatelessWidget {
  _AssignedToTab({super.key});

  // Demo data – swap with your real API data
  final List<_ClassInfo> _classes = const [
    _ClassInfo(
      classTitle: 'Grade 6 - Section A',
      subject: 'Essential Algebra for Beginners',
      time: '8:00–9:30 AM',
      duration: '90 mins',
    ),
    _ClassInfo(
      classTitle: 'Grade 6 - Section B',
      subject: 'Essential Algebra for Beginners',
      time: '10:00–11:30 AM',
      duration: '90 mins',
    ),
    _ClassInfo(
      classTitle: 'Grade 6 - Section C',
      subject: 'Essential Algebra for Beginners',
      time: '1:30–3:00 PM',
      duration: '90 mins',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: _classes.length,
      itemBuilder: (_, i) {
        final c = _classes[i];
        return GlobalBasicInformationWidget(
          classTitle: c.classTitle,
          subject: c.subject,
          time: c.time,
          duration: c.duration,
        );
      },
    );
  }
}

class _ClassInfo {
  final String classTitle;
  final String subject;
  final String time;
  final String duration;
  const _ClassInfo({
    required this.classTitle,
    required this.subject,
    required this.time,
    required this.duration,
  });
}


class _LearnersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      itemCount: 12,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: Colors.indigo.shade100,
            child: Text(
              'S${i + 1}',
              style: TextStyle(color: Colors.indigo.shade700, fontWeight: FontWeight.w600),
            ),
          ),
          title: Text('Student ${i + 1}'),
          subtitle: const Text('Active • Last seen 2h ago'),
          trailing: Icon(Icons.chevron_right, color: Colors.black.withOpacity(.3)),
          onTap: () {},
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            letterSpacing: .6,
            fontWeight: FontWeight.bold,
            fontSize: 20
          ),
    );
  }
}

class _MutedRow extends StatelessWidget {
  const _MutedRow(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.schedule, size: 16, color: Colors.black45),
        const SizedBox(width: 6),
        Text(text, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
      ],
    );
  }
}

class _ChipPill extends StatelessWidget {
  const _ChipPill(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}
