import 'package:doctor_app/components/appointment_card.dart';
import 'package:doctor_app/screens/home_screen.dart';
import 'package:doctor_app/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

enum FilterStatus { upcoming, complete, cancel }

class _AppointmentScreenState extends State<AppointmentScreen> {
  FilterStatus status = FilterStatus.upcoming;
  Alignment _alignment = Alignment.centerLeft;

  List<dynamic> shedules = [
    {
      "doctor_name": " Dr Will Smith",
      "doctor_profile": "assets/images/doctor1.jpg",
      "category": "Dental",
      "status": FilterStatus.upcoming,
    },
    {
      "doctor_name": "Dr Anna",
      "doctor_profile": "assets/images/doctor4.jpg",
      "category": "Physiotherapist",
      "status": FilterStatus.complete,
    },
    {
      "doctor_name": " Dr Nazeer Ahmed",
      "doctor_profile": "assets/images/doctor3.jpg",
      "category": "General",
      "status": FilterStatus.complete,
    },
    {
      "doctor_name": " Dr Kethrine",
      "doctor_profile": "assets/images/doctor2.jpg",
      "category": "Dental",
      "status": FilterStatus.cancel,
    }
  ];
  @override
  Widget build(BuildContext context) {
     var filteredShedule = shedules.where((var shedule) {
      return shedule["status"] == status;
    }).toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Appointment Filter",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Config.spaceSmall,
            Stack(
              children: [
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (FilterStatus filterStatus in FilterStatus.values)
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (filterStatus == FilterStatus.upcoming) {
                                  status = FilterStatus.upcoming;
                                  _alignment = Alignment.centerLeft;
                                } else if (filterStatus ==
                                    FilterStatus.complete) {
                                  status = FilterStatus.complete;
                                  _alignment = Alignment.center;
                                } else {
                                  status = FilterStatus.cancel;
                                  _alignment = Alignment.centerRight;
                                }
                              });
                            },
                            child: Center(
                              child: Text(filterStatus.name),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                AnimatedAlign(
                  alignment: _alignment,
                  duration: Duration(microseconds: 200),
                  child: Container(
                    width: 100,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Config.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                        child: Text(
                      status.name,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    )),
                  ),
                ),


              ],
            ),

            Config.spaceSmall,

            Expanded(
              child: ListView.builder(
                  itemCount: filteredShedule.length,
                  itemBuilder: (context, index) {
                    var _shedules = filteredShedule[index];
                    bool isLastElement =
                        filteredShedule.length + 1 == index;
                    return Card(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Colors.grey
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: !isLastElement? EdgeInsets.only(bottom: 20) : EdgeInsets.zero,
                      child: Padding(padding: EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: AssetImage(_shedules["doctor_profile"]),
                                ),

                                SizedBox(width: 10,),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_shedules["doctor_name"], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                                    // SizedBox(height: 10,),
                                    Text(_shedules["category"], style: TextStyle(),),
                                  ],
                                ),
                              ],
                            ),
                             SizedBox(
                               height: 15,
                             ),
                            SheduleCard(),

                            SizedBox(height: 15,),

                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(

                                    onPressed: () {},
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(color: Config.primaryColor),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: ElevatedButton(
                                    style:
                                    ElevatedButton.styleFrom(backgroundColor: Config.primaryColor),
                                    onPressed: () {},
                                    child: Text(
                                      "Reshedule",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),),
                    );
                  }),
            ),


          ],
        ),
      ),
    );
  }
}

class SheduleCard extends StatelessWidget {
  const SheduleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      width: double.infinity,
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            color: Config.primaryColor,
            size: 15,
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            "Monday 24-11-2025",
            style: TextStyle(color: Config.primaryColor),
          ),
          SizedBox(
            width: 20,
          ),
          Icon(
            Icons.alarm,
            color: Config.primaryColor,
            size: 17,
          ),
          SizedBox(
            width: 5,
          ),
          Flexible(
            child: Text(
              "2:00 AM",
              style: TextStyle(color: Config.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
