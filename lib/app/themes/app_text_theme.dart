import 'package:flutter/material.dart';

class AppTextTheme {
  static TextTheme getTextTheme() {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Outfit',
        fontWeight: FontWeight.w500, 
        fontSize: 30.0,
        letterSpacing: 0.33,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Outfit',
        fontWeight: FontWeight.w500, 
        fontSize: 25.0,
        letterSpacing: 0.33,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Outfit',
        fontWeight: FontWeight.w500, 
        fontSize: 18.0,
        letterSpacing: 0.33,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Outfit',
        fontWeight: FontWeight.w500, 
        fontSize: 16.0,
        letterSpacing: 0.33,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Outfit',
        fontWeight: FontWeight.w500, 
        fontSize: 14.0,
        letterSpacing: 0.33,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Outfit',
        fontWeight: FontWeight.w500, 
        fontSize: 12.0,
        letterSpacing: 0.33,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Outfit',
        fontWeight: FontWeight.w500, 
        fontSize: 10.0,
        letterSpacing: 0.33,
      ),
    );
  }
}

