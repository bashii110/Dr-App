import 'package:flutter/material.dart';

class Config{
  static MediaQueryData? mediaQueryData;
  static double? screenWidth;
  static double? screenHeight;


  //Width and Height Initialization
  void inIt(BuildContext context){
    mediaQueryData = MediaQuery.of(context);
    screenWidth= mediaQueryData!.size.width;
    screenHeight= mediaQueryData!.size.height;
  }

  static get widhSize{
    return screenWidth;
  }

  static get heightSize{
    return screenHeight;
  }


  static const primaryColor= Colors.greenAccent;
  static const spaceSmall= SizedBox(height: 25,);
  static final spaceMedium= SizedBox(height: screenHeight! * 0.05,);
  static final spaceBig= SizedBox(height: screenHeight! * 0.08,);

  //text form field border
  static const outlinedInputBorder= OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );

  static const focusedBorder= OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: Colors.greenAccent),
  );

  static const errorBorder= OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: Colors.red),
  );


}