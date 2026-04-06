// import 'package:doctor_app/components/button.dart';
// import 'package:doctor_app/screens/patients/home_screen.dart';
// import 'package:doctor_app/utils/config.dart';
// import 'package:flutter/material.dart';
//
// class BookSucess extends StatefulWidget {
//   const BookSucess({super.key});
//
//   @override
//   State<BookSucess> createState() => _BookSccessState();
// }
//
// class _BookSccessState extends State<BookSucess> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Center(
//                 child: Container(
//                   width: double.infinity,
//                   height: 400,
//                   child: Image.asset(
//                     "assets/images/sucess.png",
//                   ),
//                 ),
//               ),
//               Config.spaceBig,
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
//                 child: Button(width: double.infinity, title: "Back to home page", onpressed: (){
//                   // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomeScreen()));
//                   Navigator.pop(context);
//                 }, disable: false),
//               ),
//             ]),
//       ),
//     );
//   }
// }
