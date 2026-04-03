import 'package:flutter/material.dart';
import '../utils/config.dart';

class RegisterForm extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final Function(String) onTypeChanged; // Add this

  const RegisterForm({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.onTypeChanged, // Add this
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  bool obsecurePass = true;
  String selectedType = 'patient'; // Default value


  @override
  void initState() {
    super.initState();
    widget.onTypeChanged('patient'); // Initialize with default
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Name Field
        TextFormField(
          controller: widget.nameController,
          keyboardType: TextInputType.name,
          cursorColor: Config.primaryColor,
          decoration: InputDecoration(
            hintText: "Enter your Name",
            labelText: "Name",
            alignLabelWithHint: true,
            prefixIcon: Icon(Icons.person),
            prefixIconColor: Config.primaryColor,
          ),
          validator: (val) {
            if (val == null || val.isEmpty) return "Name required";
            return null;
          },
        ),

        Config.spaceSmall,

        // Email Field
        TextFormField(
          controller: widget.emailController,
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
            if (val == null || val.isEmpty) return "Email required";
            return null;
          },
        ),

        Config.spaceSmall,

        // Password Field
        TextFormField(
          controller: widget.passwordController,
          keyboardType: TextInputType.visiblePassword,
          obscureText: obsecurePass,
          cursorColor: Config.primaryColor,
          decoration: InputDecoration(
            hintText: "Enter your Password",
            labelText: "Password",
            alignLabelWithHint: true,
            prefixIcon: Icon(Icons.lock_open),
            prefixIconColor: Config.primaryColor,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() => obsecurePass = !obsecurePass);
              },
              icon: Icon(
                obsecurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: obsecurePass ? Colors.black38 : Config.primaryColor,
              ),
            ),
          ),
          validator: (val) {
            if (val == null || val.isEmpty) return "Password required";
            if (val.length < 6) return "Password must be at least 6 characters";
            return null;
          },
        ),

        Config.spaceSmall,

        // User Type Selection - NEW
        Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Register as:",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('Patient'),
                      value: 'patient',
                      groupValue: selectedType,
                      activeColor: Config.primaryColor,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) {
                        setState(() {
                          selectedType = value!;
                          widget.onTypeChanged(value);
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('Doctor'),
                      value: 'doctor',
                      groupValue: selectedType,
                      activeColor: Config.primaryColor,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) {
                        setState(() {
                          selectedType = value!;
                          widget.onTypeChanged(value);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}