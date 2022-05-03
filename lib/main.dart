import 'package:flutter/material.dart';
import 'screen/ContentScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  final MaterialColor? mainColor = Colors.red;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile Application 1',
      theme: ThemeData(
        primarySwatch: mainColor,
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(backgroundColor: mainColor![900]),
        drawerTheme: DrawerThemeData(backgroundColor: mainColor![900])
      ),
      debugShowCheckedModeBanner: false,
      home: const ContentScreen(title: 'Mobile Application 1'),
    );
  }
}