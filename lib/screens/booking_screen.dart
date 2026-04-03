import 'package:doctor_app/components/button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

import '../utils/config.dart';
import 'book_sccess.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  CalendarFormat _format = CalendarFormat.month;
  DateTime _focusDate = DateTime.now();
  DateTime _currentDate = DateTime.now();
  int? currentIndex;
  bool isWeekend = false;
  bool dateSelected = false;
  bool timeSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(top: 20, left: 18),
          child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: FaIcon(
                Icons.arrow_back_ios,
                color: Config.primaryColor,
              )),
        ),
        title: Text("Booking"),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                _tableCalender(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                  child: Text(
                    "Select Consultation time",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
          isWeekend
              ? SliverToBoxAdapter(
                  child: Container(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 30,
                      ),
                      child: Text(
                        "Weekend is not available, Please select another date.",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                    ),
                  ),
                )
              : SliverGrid(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return InkWell(
                      splashColor: Colors.transparent,
                      onTap: () {
                        setState(() {
                          currentIndex = index;
                          timeSelected = true;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: currentIndex == index
                                ? Colors.white
                                : Colors.black,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          color: currentIndex == index
                              ? Config.primaryColor
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "${index + 9}:00 ${index + 9 > 11 ? "PM" : "AM"}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  currentIndex == index ? Colors.white : null),
                        ),
                      ),
                    );
                  }, childCount: 8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, childAspectRatio: 1.5),
                ),
          SliverToBoxAdapter(

            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 50),
              child: Button(
                width: double.infinity,
                title: "Make Appointment",
                onpressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> BookSucess()));
                },
                disable: timeSelected && dateSelected ? false : true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableCalender() {
    return TableCalendar(
      focusedDay: _focusDate,
      firstDay: DateTime.now(),
      lastDay: DateTime(2026, 12, 23),
      calendarFormat: _format,
      currentDay: _currentDate,
      rowHeight: 48,
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Config.primaryColor,
          shape: BoxShape.circle,
        ),
      ),
      availableCalendarFormats: {
        CalendarFormat.month: "Months",
      },
      onFormatChanged: (format) {
        setState(() {
          _format = format;
        });
      },
      onDaySelected: ((selectedDay, focusDay) {
        setState(() {
          _currentDate = selectedDay;
          _focusDate = focusDay;
          dateSelected = true;

          //Check if its weekend
          if (selectedDay.weekday == 6 || selectedDay.weekday == 7) {
            isWeekend = true;
            timeSelected = false;
            currentIndex = null;
          } else {
            isWeekend = false;
          }
        });
      }),
    );
  }
}
