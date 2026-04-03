import 'package:doctor_app/auth/registration_screen.dart';
import 'package:doctor_app/form/login_form.dart';
import 'package:doctor_app/components/social_button.dart';
import 'package:doctor_app/utils/config.dart';
import 'package:doctor_app/utils/main_layout.dart';
import 'package:doctor_app/utils/text.dart';
import 'package:flutter/material.dart';

import '../components/button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {



  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  String name = '', email = '', password = '';
  bool loading = false;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // closes keyboard
      },
      child: Scaffold(
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  Apptext.enText['welcome-text']!,
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),
                Config.spaceSmall,
                Text(
                  Apptext.enText['signIn-text']!,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Config.spaceSmall,
                LoginForm(),
                Config.spaceSmall,


                // Login Button
                Button(
                  width: double.infinity,
                  title: 'Sign In',
                  onpressed: () {
                    // Navigator.of(context).pushNamed("main");
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> MainLayout()));
                  },
                  disable: false,
                ),


                Config.spaceSmall,
                TextButton(
                  onPressed: () {},
                  child: Text(
                    Apptext.enText['forget-password']!,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),

                Config.spaceSmall,

                Text(
                  Apptext.enText['social-login']!,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.grey.shade500),
                ),

                Config.spaceSmall,

                SocialButton(social: "google"),
                Config.spaceSmall,
                SocialButton(social: "facebook"),

                Config.spaceSmall,

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      Apptext.enText['signUp-text']!,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.grey.shade500),
                    ),

                    TextButton(onPressed: (){
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> RegistrationScreen()));
                    }, child: Text(
                      Apptext.enText['signUp']!,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    ))
                  ],
                )

              ],
            ),
          ),
        )),
      ),
    );
  }
}
