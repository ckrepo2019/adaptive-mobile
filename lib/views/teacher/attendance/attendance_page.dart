import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final students = [
      "Alyssa Mae Santos",
      "John Carlo Dela Cruz",
      "Maria Angelica Reyes",
      "James Ryan Mendoza",
      "Katherine Anne Gomez",
      "Miguel Antonio Ramirez",
      "Ellaine Grace Torres",
      "Joshua Paul Villanueva",
      "Christine Joy Navarro",
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () {},
          icon: Icon(Icons.arrow_back_ios), color: Colors.white,),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Attendance",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            Text(
              "Essential Algebra for Beginners",
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _attendanceButton("Present", Colors.green),
                _attendanceButton("Late", Colors.orange),
                _attendanceButton("Absent", Colors.red),
              ],
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          // Student table header
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Name", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text("Status", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Student list
          Expanded(
            child: ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(value: false, onChanged: (v) {}),
                          Text(students[index]),
                        ],
                      ),
                      Switch(
                        value: true,
                        onChanged: (v) {},
                        activeColor: Colors.green,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _attendanceButton(String text, MaterialColor color) {
    return Container(
      width: 110,
      height: 30,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: color.shade100,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
