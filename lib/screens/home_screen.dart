import 'package:doctor_app/components/appointment_card.dart';
import 'package:doctor_app/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


import 'doctors_details.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> medCat = [
    {"icon": FontAwesomeIcons.userDoctor, "category": "General"},
    {"icon": FontAwesomeIcons.heartPulse, "category": "Cardiology"},
    {"icon": FontAwesomeIcons.lungs, "category": "Respirations"},
    {"icon": FontAwesomeIcons.hand, "category": "Dermitology"},
    {"icon": FontAwesomeIcons.personPregnant, "category": "Gynocology"},
    {"icon": FontAwesomeIcons.teeth, "category": "Dental"},
  ];

  @override
  Widget build(BuildContext context) {
    Config().inIt(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Rony",
                      style: TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    CircleAvatar(
                      radius: 30,
                      backgroundImage:
                      AssetImage("assets/images/profile1.jpg"),
                    )
                  ],
                ),
                Config.spaceMedium,

                // Categories
                Text(
                  "Category",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Config.spaceSmall,
                SizedBox(
                  height: Config.heightSize * 0.08,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: medCat.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(right: 15),
                        padding: EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            FaIcon(
                              medCat[index]['icon'],
                              color: Colors.white,
                            ),
                            SizedBox(width: 10),
                            Text(
                              medCat[index]['category'],
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Config.spaceSmall,

                // Appointments
                Text(
                  "Appointments Today",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Config.spaceSmall,
                AppointmentCard(),
                Config.spaceSmall,

                // Top Doctors
                Text(
                  "Top Doctors",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Config.spaceSmall,
                Column(
                  children: List.generate(10, (index){

                    // Doctor Card Here
                    return  Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: GestureDetector(
                          child: Card(
                            elevation: 5,
                            color: Colors.white,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: Config.widhSize * 0.33,
                                  child: Image.asset(
                                    "assets/images/ana.jpg",
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                Flexible(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Dr Ana Richards", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                                        Text("Dentist", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18),),

                                        SizedBox(height: 60),



                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Icon(Icons.star_border, color: Colors.yellow,),
                                            SizedBox(width: 4,),
                                            Text("4.7"),
                                            SizedBox(width: 10,),
                                            Text("Reviews"),
                                            SizedBox(width: 4,),
                                            Text("(20)"),



                                          ],
                                        )
                                      ],

                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> DoctorsDetails()));
                          }, //Redirect to Doctors Details
                        ),
                      );
                  })
                  ,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
