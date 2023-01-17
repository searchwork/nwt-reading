import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  useMaterial3: true,
  appBarTheme: const AppBarTheme(
      actionsIconTheme: IconThemeData(color: Color(0xff007bff)),
      backgroundColor: Color(0xfff6f6f6),
      foregroundColor: Color(0xff000000)),
  cardTheme: const CardTheme(
    clipBehavior: Clip.antiAliasWithSaveLayer,
    elevation: 10,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0))),
  ),
  primaryColor: const Color(0xff007bff),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    circularTrackColor: Color(0xfff6f6f6),
    color: Color(0xff28a745),
    linearMinHeight: 3,
    linearTrackColor: Color(0xfff6f6f6),
  ),
  scaffoldBackgroundColor: const Color(0xfff6f6f6),
);

final darkTheme = ThemeData.dark();
