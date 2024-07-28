import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  colorSchemeSeed: const Color(0xff007bff),
  brightness: Brightness.light,
  appBarTheme: const AppBarTheme(
    actionsIconTheme: IconThemeData(color: Color(0xff007bff)),
  ),
  cardTheme: const CardTheme(
    clipBehavior: Clip.antiAliasWithSaveLayer,
    elevation: 10,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0))),
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    circularTrackColor: Colors.black12,
  ),
);

final darkTheme = ThemeData(
  colorSchemeSeed: const Color(0xff007bff),
  brightness: Brightness.dark,
  appBarTheme: const AppBarTheme(
    actionsIconTheme: IconThemeData(color: Color(0xff007bff)),
  ),
  cardTheme: const CardTheme(
    clipBehavior: Clip.antiAliasWithSaveLayer,
    elevation: 10,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0))),
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    circularTrackColor: Colors.black12,
  ),
);
