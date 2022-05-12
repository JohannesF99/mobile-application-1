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

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {

  /// Beschreibt, welches Thema für die App gerade festgelegt ist.
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
            return const Center(
                child: CircularProgressIndicator()
            );
          }
        },
      )
    );
  }

  /// Untersucht, ob ein Login-Token in den Shared Preferences existiert.
  /// Falls nicht, so ist kein User angemeldet und er gibt 'false' zurück.
  /// Falls ja, so ist schon ein User angemeldet und er gibt 'ja' zurück.
  Future<bool> showLoginPage() async {
    var token = await StorageManager.readData("token");
    return token == null;
  }

  /// Wechselt das Thema.
  /// Anschließend wird 'setState()' aufgerufen, um den Widget-Tree neu zu
  /// generieren und die Änderung sichtbar zu machen.
  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }
}