import 'package:flutter/material.dart';

/// Beschreibt das Light- und Dark-Theme der Anwendung.
/// Durch die Kapselung als seperate Klasse können alle Design-Entscheidungen
/// in dieser Datei getroffen werden.
class AppThemes{
  /// Das helle Thema der Anwendung.
  /// Deklariert als statische Variable, sodass kein Objekt der Klasse benötigt
  /// wird, um auf das Thema zuzugreifen.
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
              fontSize: 15
          )
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.red[900]
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: Colors.red[900],
          )
      ),
  );

  /// Das dunkle Thema der Anwendung.
  /// Deklariert als statische Variable, sodass kein Objekt der Klasse benötigt
  /// wird, um auf das Thema zuzugreifen.
  static final darkTheme = ThemeData(
      brightness: Brightness.dark,
      iconTheme: const IconThemeData(color: Colors.white),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawerTheme: const DrawerThemeData(
          backgroundColor: Colors.black,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(
          fontSize: 15,
          color: Colors.white
        )
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.white
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: Colors.black,
          )
      ),
  );
}