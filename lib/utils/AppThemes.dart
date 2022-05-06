import 'package:flutter/material.dart';

class AppThemes{
  static final lightTheme = ThemeData(
      primarySwatch: Colors.red,
      brightness: Brightness.light,
      iconTheme: const IconThemeData(color: Colors.black),
      appBarTheme: AppBarTheme(
          backgroundColor: Colors.red[900],
        titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
        ),
          iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawerTheme: DrawerThemeData(
          backgroundColor: Colors.red[900]
      ),
      textTheme: const TextTheme(
          bodyMedium: TextStyle(
              fontSize: 20
          )
      )
  );

  static final darkTheme = ThemeData(
      primarySwatch: Colors.red,
      brightness: Brightness.dark,
      iconTheme: const IconThemeData(color: Colors.white),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.red[900],
        titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      drawerTheme: DrawerThemeData(
          backgroundColor: Colors.red[900],
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(
          fontSize: 20
        )
      )
  );
}