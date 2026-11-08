import 'package:flutter/material.dart';

const _seed = Color(0xFF2E7D6B);

ThemeData buildLightTheme() => ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: _seed),
  useMaterial3: true,
);

ThemeData buildDarkTheme() => ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: _seed,
    brightness: Brightness.dark,
  ),
  useMaterial3: true,
);
