import 'package:flutter/material.dart';

class AppThemes{
  static final lightTheme = ThemeData(
      primarySwatch: Colors.red,
      brightness: Brightness.light,
      appBarTheme: AppBarTheme(backgroundColor: Colors.red[900]),
      drawerTheme: DrawerThemeData(backgroundColor: Colors.red[900])
  );

  static final darkTheme = ThemeData(
      primarySwatch: Colors.red,
      brightness: Brightness.dark,
      appBarTheme: AppBarTheme(backgroundColor: Colors.red[900]),
      drawerTheme: DrawerThemeData(backgroundColor: Colors.red[900])
  );
}