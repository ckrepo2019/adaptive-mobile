import 'package:flutter/material.dart';
import 'package:flutter_lms/views/student/student_global_layout.dart';
import 'package:flutter_lms/widgets/app_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedMonth = DateTime.now();

  List<Widget> _buildCalendarDays(DateTime month, double cellSize) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    List<Widget> dayWidgets = [];

    for (int i = 0; i < firstWeekday; i++) {
      dayWidgets.add(SizedBox(width: cellSize, height: cellSize));
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final isToday =
          DateTime.now().day == day &&
          DateTime.now().month == month.month &&
          DateTime.now().year == month.year;

      dayWidgets.add(
        Container(
          width: cellSize,
          height: cellSize,
          decoration: isToday
              ? BoxDecoration(color: Colors.deepOrange, shape: BoxShape.circle)
              : null,
          child: Center(
            child: Text(
              "$day",
              style: GoogleFonts.poppins(
                fontSize: cellSize * 0.35,
                fontWeight: FontWeight.bold,
                color: isToday ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ),
        ),
      );
    }

    return dayWidgets;
  }

  @override
  Widget build(BuildContext context) {
    final monthName = DateFormat("MMMM yyyy").format(_focusedMonth);

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final cellSize = screenWidth / 9;
    final calendarHeight = screenHeight * 0.45;

    return StudentGlobalLayout(
      useSafeArea: false,
      useScaffold: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Card(
            elevation: 20,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 0, 52, 248),
                    Color.fromARGB(255, 8, 43, 171),
                  ],
                  stops: [0.1, 0.8],
                ),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Your Streak",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          "22 Days",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 40,
                            color: Colors.white,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: -MediaQuery.of(context).size.height * 0.04,
                    right: -MediaQuery.of(context).size.width * 0.05,
                    child: Image.asset(
                      "assets/images/utilities/streak_icon.png",
                      height: MediaQuery.of(context).size.height * 0.15,
                      width: MediaQuery.of(context).size.width * 0.25,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          Card(
            elevation: 5,
            child: Container(
              height: calendarHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _focusedMonth = DateTime(
                                _focusedMonth.year,
                                _focusedMonth.month - 1,
                              );
                            });
                          },
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: screenWidth * 0.04,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        Text(
                          monthName,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.045,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _focusedMonth = DateTime(
                                _focusedMonth.year,
                                _focusedMonth.month + 1,
                              );
                            });
                          },
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: screenWidth * 0.04,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:
                          ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                              .map(
                                (day) => Expanded(
                                  child: Center(
                                    child: Text(
                                      day,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: screenWidth * 0.03,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: GridView.count(
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 7,
                        children: _buildCalendarDays(_focusedMonth, cellSize),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
