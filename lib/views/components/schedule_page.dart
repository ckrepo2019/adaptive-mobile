import 'package:flutter/material.dart';
import 'package:flutter_lms/widgets/app_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  bool isEditing = false; // ✅ Toggle state

  final List<Map<String, String>> schedule = [
    {"day": "Monday", "time": "1:00 PM - 2:00 PM"},
    {"day": "Tuesday", "time": "2:00 PM - 3:00 PM"},
    {"day": "Wednesday", "time": "10:00 AM - 11:00 AM"},
    {"day": "Thursday", "time": "11:00 AM - 12:00 PM"},
    {"day": "Friday", "time": "9:00 AM - 10:00 AM"},
  ];

  Future<void> _editTime(int index) async {
    final TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (startTime == null) return;

    final TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: startTime,
    );
    if (endTime == null) return;

    String formatTime(TimeOfDay t) {
      return t.format(context);
    }

    setState(() {
      schedule[index]["time"] =
          "${formatTime(startTime)} - ${formatTime(endTime)}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GlobalAppBar(
        title: 'Schedule',
        subtitle: 'Essential Algebra for Beginners',
        showBack: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Table(
              border: TableBorder.all(color: Colors.grey.shade300, width: 1),
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
              },
              children: [
                // Header
                TableRow(
                  decoration: BoxDecoration(color: Colors.blue.shade100),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('Day',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('Schedule Time',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                // Data rows
                ...schedule.asMap().entries.map((entry) {
                  int index = entry.key;
                  String day = entry.value["day"]!;
                  String time = entry.value["time"]!;

                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(day),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: isEditing
                            ? InkWell(
                                onTap: () => _editTime(index),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.blue, width: 1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    time,
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                ),
                              )
                            : Text(time),
                      ),
                    ],
                  );
                }),
              ],
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                setState(() {
                  isEditing = !isEditing; // ✅ Toggle edit state
                });
              },
              child: Container(
                padding: const EdgeInsets.all(5),
                height: 40,
                width: 140,
                decoration: BoxDecoration(
                  color: isEditing ? Colors.green : Colors.blue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    isEditing ? "Save Schedule" : "Edit Schedule",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
