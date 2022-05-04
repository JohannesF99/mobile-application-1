import 'package:flutter/material.dart';
import 'package:mobileapplication1/screen/LoginScreen.dart';
import 'package:mobileapplication1/utils/AppThemes.dart';
import 'package:mobileapplication1/utils/StoreManager.dart';
import 'screen/ContentScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();

  /// InheritedWidget style accessor to our State object.
  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  /// 1) our themeMode "state" field
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile Application 1',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: showLoginPage(),
        builder: (buildContext, snapshot) {
          if(snapshot.hasData) {
            if(snapshot.data!){
              return const LoginScreen();
            }
            return const ContentScreen();
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ));
  }

  Future<bool> showLoginPage() async {
    var token = await StorageManager.readData("token");
    return token == null;
  }

  /// 3) Call this to change theme from any context using "of" accessor
  /// e.g.:
  /// MyApp.of(context).changeTheme(ThemeMode.dark);
  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }
}