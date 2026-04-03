import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/config.dart';

class Button extends StatelessWidget {
  const Button({super.key, required this.width, required this.title, required this.onpressed, required this.disable});

  final double width;
  final String title;
  final bool disable; // Used to disable button
  final Function() onpressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Config.primaryColor,
          foregroundColor: Colors.white
        ),
        onPressed: disable ? null : onpressed,
        child: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
