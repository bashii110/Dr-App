import 'package:doctor_app/auth/login_screen.dart';
import 'package:doctor_app/form/login_form.dart';
import 'package:doctor_app/form/registration_form.dart';
import 'package:doctor_app/components/social_button.dart';
import 'package:doctor_app/utils/config.dart';
import 'package:doctor_app/utils/main_layout.dart';
import 'package:doctor_app/utils/text.dart';
import 'package:flutter/material.dart';

import '../components/button.dart';
import '../service/api_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool loading = false;

  String name = '', email = '', password = '';
  String userType = 'patient'; // Add this

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
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
                      Apptext.enText['signUp-text1']!,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Config.spaceSmall,
                    Form(
                      key: _formKey,
                      child: RegisterForm(
                        nameController: nameCtrl,
                        emailController: emailCtrl,
                        passwordController: passwordCtrl,
                        onTypeChanged: (type) {
                          userType = type; // Capture the selected type
                        },
                      ),
                    ),
                    Config.spaceSmall,

                    loading
                        ? CircularProgressIndicator()
                        : Button(
                      width: double.infinity,
                      title: 'Sign Up',
                      onpressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            loading = true;
                          });

                          try {
                            name = nameCtrl.text.trim();
                            email = emailCtrl.text.trim();
                            password = passwordCtrl.text.trim();

                            print('Registering with type: $userType');

                            final res = await ApiService.registerUser(
                              name: name,
                              email: email,
                              password: password,
                              type: userType,
                            );

                            if (res['status'] == 200 || res['status'] == 201) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(res['message'])),
                              );
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        res['message'] ?? "Error registering")),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Registration failed: $e")),
                            );
                          } finally {
                            if (mounted) {
                              setState(() {
                                loading = false;
                              });
                            }
                          }
                        }
                      },
                      disable: false,
                    ),

                // Config.spaceSmall,
                // TextButton(
                //   onPressed: () {},
                //   child: Text(
                //     Apptext.enText['forget-password']!,
                //     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                //   ),
                // ),

                Config.spaceSmall,

                Text(
                  Apptext.enText['social-login']!,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey.shade500),
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
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey.shade500),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()));
                        },
                        child: Text(
                          Apptext.enText['logIn']!,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
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
