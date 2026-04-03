import 'package:doctor_app/screens/booking_screen.dart';
import 'package:doctor_app/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../components/button.dart';

class DoctorsDetails extends StatefulWidget {
  const DoctorsDetails({super.key});

  @override
  State<DoctorsDetails> createState() => _DoctorsDetailsState();
}

class _DoctorsDetailsState extends State<DoctorsDetails> {
  bool isFav = false;

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
        title: Text("Doctor's Details"),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isFav = !isFav;
              });
            },
            icon: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: FaIcon(
                !isFav ? Icons.favorite_outline : Icons.favorite,
                color: Config.primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 3),
            AboutDoctor(),
            DetailsBody(),

            Padding(
              padding: EdgeInsets.all(20),
              child: Button(
                title: "Book Appointment",
                disable: false,
                width: double.infinity,
                onpressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> BookingScreen()));
                },
              ),
            ),
          ],
        ),
      )),
    );
  }
}

class AboutDoctor extends StatelessWidget {
  const AboutDoctor({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          CircleAvatar(
            radius: 65.5,
            backgroundImage: AssetImage("assets/images/doctor4.jpg"),
            backgroundColor: Colors.white,
          ),
          Config.spaceMedium,
          Text(
            "Dr Anna Williams",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Config.spaceSmall,
          SizedBox(
            width: Config.widhSize * 0.75,
            child: Text(
              "MBBS (International Medical University, Malaysia), MRCP(Royal College of Physicians, United Kingdom)",
              style: TextStyle(color: Colors.grey, fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ),
          Config.spaceSmall,
          SizedBox(
            width: Config.widhSize * 0.75,
            child: Text(
              "PIMS Hospital, Islamabad",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class DetailsBody extends StatelessWidget {
  const DetailsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DoctorInfo(),
          Config.spaceSmall,
          Text(
            "About Doctor",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          Config.spaceSmall,
          Text(
            "Doctor Anna Williams is an Experienced doctor at PIMS Islamabad. She has graduated from International Medical University, Malaysia",
            style: TextStyle(fontWeight: FontWeight.w500, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class DoctorInfo extends StatelessWidget {
  const DoctorInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InfoCard(lable: "Experience", value: "10 Years"),
        SizedBox(
          width: 15,
        ),
        InfoCard(lable: "Patients", value: "102"),
        SizedBox(
          width: 15,
        ),
        InfoCard(lable: "Ratings", value: "4.6"),
      ],
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.lable, required this.value});

  final String lable;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Config.primaryColor,
      ),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Column(
        children: [
          Text(
            lable,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            value,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    ));
  }
}
