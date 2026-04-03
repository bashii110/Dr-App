import 'package:doctor_app/auth/login_screen.dart';
import 'package:doctor_app/auth/registration_screen.dart';
import 'package:doctor_app/screens/doctors_details.dart';
import 'package:doctor_app/utils/config.dart';
import 'package:doctor_app/utils/main_layout.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  //For push Navigator
  static final navigatorKey= GlobalKey<NavigatorState>();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Doctor App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        inputDecorationTheme: const InputDecorationTheme(
          focusColor: Config.primaryColor,
          border: Config.outlinedInputBorder,
          focusedBorder: Config.focusedBorder,
          errorBorder: Config.errorBorder,
          enabledBorder: Config.outlinedInputBorder,
          floatingLabelStyle: TextStyle(
            color: Config.primaryColor,
          ),
          prefixIconColor: Colors.black38,
        ),
        scaffoldBackgroundColor: Colors.white,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Config.primaryColor,
          selectedItemColor: Colors.white,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          unselectedItemColor: Colors.grey.shade700,
          elevation: 10,
          type: BottomNavigationBarType.fixed
        ),

      ),
      // initialRoute: "/",
      // routes: {
      //   //This is the initial route of the application
      //   '/': (context) => const AuthScreen(),
      //   'main':(context) => const MainLayout(),
      //   "doc_details" : (context) => const DoctorsDetails(),
      // },

      home: LoginScreen(),
    );
  }
}

