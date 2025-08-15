import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const MaterialColor kPrimaryColor =
      MaterialColor(0xFFEE4463, <int, Color>{
        50: Color(0x88FFC7FF),
        100: Color(0xFFFFC7FF),
        200: Color(0xFFF1A6AA),
        300: Color(0xFFFF99E0),
        400: Color(0xFFFF6DA3),
        500: Color(0xFFEE4463),
        600: Color(0xFFEE4463),
        700: Color(0xFFEE4463),
        800: Color(0xFFEE4463),
        900: Color(0xFF895E6B),
      });
  static const LinearGradient gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF5069), Color(0xFF9C58C0), Color(0xFF3F6AE6)],
    stops: [0.1074, 0.5117, 0.916],
  );
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Color(0x00000000);
  static const Color green = Color(0xFF43A838);
  static const Color red = Color(0xFFFF3B3B);
  static const Color gray = Color(0xFFAAAAAA);
  static const Color lightGray = Color(0xFF909296);
  static const Color colorDivider = Color(0xFFEBEBEB);

  static const Color neutral6 = Color(0xFFF1F2F9);
  static const Color neutral3 = Color(0xFFADAFC5);
}
