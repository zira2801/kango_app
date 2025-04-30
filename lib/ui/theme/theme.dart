import 'package:flutter/material.dart';

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF007D88),
  onPrimary: Color(0xFFFFFFFF),
  secondary: Color(0xFFFFC400),
  onSecondary: Color(0xFFFFFFFF),
  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  background: Color(0xFFFFFFFF),
  onBackground: Color(0xFF000000),
  shadow: Color(0xFF000000),
  outlineVariant: Color(0xFFC2C8BC),
  surface: Color.fromARGB(255, 222, 222, 222),
  onSurface: Color(0xFF1A1C18),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF007D88),
  onPrimary: Color(0xFF000000),
  secondary: Color(0xFFFFC400),
  onSecondary: Color(0xFF000000),
  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  background: Color(0xFF000000),
  onBackground: Color(0xFFFFFFFF),
  shadow: Color(0xFF000000),
  outlineVariant: Color(0xFFC2C8BC),
  surface: Color.fromARGB(255, 222, 222, 222),
  onSurface: Color(0xFF1A1C18),
);
// const darkColorScheme = ColorScheme(
//   brightness: Brightness.dark,
//   primary: Color(0xFF007D88),
//   onPrimary: Color(0xFFFFFFFF),
//   secondary: Color(0xFFFFC400),
//   onSecondary: Color(0xFFFFFFFF),
//   error: Color(0xFFBA1A1A),
//   onError: Color(0xFFFFFFFF),
//   background: Color(0xFF000000),
//   onBackground: Color(0xFFFFFFFF),
//   shadow: Color(0xFF000000),
//   outlineVariant: Color(0xFFC2C8BC),
//   surface: Color.fromARGB(255, 222, 222, 222),
//   onSurface: Color(0xFF1A1C18),
// );

class ThemeDataStyle {
  static ThemeData lightMode = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: lightColorScheme,
  );

  static ThemeData darkMode = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: darkColorScheme,
  );
}

const yellow = Color.fromRGBO(250, 198, 11, 1);
