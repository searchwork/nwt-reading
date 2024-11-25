import 'package:flutter/material.dart';

final seedColor = const Color(0xff007bff);

final ColorScheme lightColorScheme = ColorScheme.fromSeed(seedColor: seedColor);
final ColorScheme darkColorScheme =
    ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.dark);
final CardTheme cardTheme = const CardTheme(
  clipBehavior: Clip.antiAliasWithSaveLayer,
  elevation: 10,
  shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(20.0))),
);

final lightTheme = ThemeData(
  colorScheme: lightColorScheme,
  cardTheme: cardTheme,
  progressIndicatorTheme: ProgressIndicatorThemeData(
    circularTrackColor: lightColorScheme.surfaceDim,
  ),
);

final darkTheme = ThemeData(
  colorScheme: darkColorScheme,
  cardTheme: cardTheme,
  progressIndicatorTheme: ProgressIndicatorThemeData(
    circularTrackColor: darkColorScheme.surfaceDim,
  ),
);
