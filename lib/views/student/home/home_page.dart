import 'package:flutter_lms/widgets/achievements_widget.dart';
import 'package:flutter_lms/widgets/assignment_card_widget.dart';
import 'package:flutter_lms/widgets/class_progress_widget.dart';

import '/views/base_view.dart';
import 'package:flutter/material.dart';

class HomePage extends BaseView {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      "Home",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () {
                        // Will do something here if I am in the mood xD
                      },
                      icon: Icon(
                        Icons.notifications_none,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Will do something here if I am in the mood xD
                      },
                      icon: Icon(Icons.person, color: Colors.grey.shade500),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(radius: 36, child: Icon(Icons.person)),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome Emma.",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 24,
                          ),
                        ),
                        Text(
                          "Visual Learner",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Achievements(
                      color: Colors.yellow.shade200,
                      icon: Icons.filter_7,
                      title: '7 Days Streak',
                      titleColor: Colors.orange,
                      iconColor: Colors.orange,
                    ),
                    SizedBox(width: 5),
                    Achievements(
                      color: Colors.lightBlueAccent,
                      icon: Icons.local_drink,
                      title: 'Freeze',
                      titleColor: Colors.blue,
                      iconColor: Colors.blue,
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Icon(Icons.assignment),
                    SizedBox(width: 5),
                    Text("My Assignments"),
                  ],
                ),
                SizedBox(height: 20),
                const CardWidget(
                  subject: 'Mathematics',
                  duration: '20 mins',
                  title: 'Math Quiz: Quadratic Equations',
                  deadline: '3:00PM',
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(5),
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      "View all Assignments",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Icon(Icons.note),
                    SizedBox(width: 5),
                    Text("Class Progress"),
                  ],
                ),

                SizedBox(height: 20),
                // This is something for progress bar?
                ClassProgressWidget(),

                SizedBox(height: 20),
                Row(
                  children: [
                    Icon(Icons.av_timer_rounded),
                    SizedBox(width: 5),
                    Text("Quick Actions", style: TextStyle()),
                  ],
                ),

                SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OptionWidget(title: 'Lessons', icon: Icons.menu_book),
                    OptionWidget(title: 'Assignments', icon: Icons.assignment),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OptionWidget extends StatelessWidget {
  final String title;
  final IconData icon;

  const OptionWidget({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 180,
        height: 180,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min, // Center vertically
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32),
              SizedBox(height: 8),
              Text(title, style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
