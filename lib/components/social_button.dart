import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  const SocialButton({super.key, required this.social});

  final String social;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        onPressed: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/$social.png",
              width: 35,
              height: 35,
            ),
            SizedBox(width: 20,),
            Text(
              social.toUpperCase(),
              style: TextStyle(color: Colors.black38),
            )
          ],
        ));
  }
}
