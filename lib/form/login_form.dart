import 'package:flutter/material.dart';

import '../utils/config.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailControllor = TextEditingController();
  final _passControllor = TextEditingController();

  String  email = '', password = '';
  bool loading = false;

  bool obsecurePass = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            controller: _emailControllor,
            keyboardType: TextInputType.emailAddress,
            cursorColor: Config.primaryColor,
            decoration: InputDecoration(
              hintText: "Enter your Email",
              labelText: "Email",
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.email),
              prefixIconColor: Config.primaryColor,
            ),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return "Email required";
              }
              return null;
            },
          ),
          Config.spaceSmall,
          TextFormField(
            controller: _passControllor,
            keyboardType: TextInputType.visiblePassword,
            cursorColor: Config.primaryColor,
            obscureText: obsecurePass,
            decoration: InputDecoration(
              hintText: "Enter your Password",
              labelText: "Password",
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.lock_open),
              prefixIconColor: Config.primaryColor,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    obsecurePass = !obsecurePass;
                  });
                },
                icon: obsecurePass
                    ? Icon(
                        Icons.visibility_off_outlined,
                        color: Colors.black38,
                      )
                    : Icon(
                        Icons.visibility_outlined,
                        color: Config.primaryColor,
                      ),
              ),
            ),
            validator: (val){
              if(val==null || val.isEmpty ){
                return "Password required";
              } else if( val.length<6){
                return "Password must be greater or equal to 6 characters";
              }
              return null;
            },
          ),


          // loading
          //     ? CircularProgressIndicator()
              // : ElevatedButton(onPressed: submit, child: Text('Register')),
        ],
      ),
    );
  }



}
