import 'package:flutter/material.dart';
import 'package:mobileapplication1/screen/RegisterScreen.dart';

import '../api/BackendAPI.dart';
import '../model/LoginData.dart';
import '../utils/StoreManager.dart';
import 'ContentScreen.dart';

/// Beschreibt den Login-Vorgang als Seite.
/// Sollte noch kein Account vorhanden sein, so wird auf den [RegisterScreen]
/// verwiesen.
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {

  /// Controller für das Textfeld des Benutzernamens.
  /// Wird verwendet, um auf den Text des Textfelds zuzugreifen.
  final _usernameController = TextEditingController();

  /// Controller für das Textfeld des Passworts.
  /// Wird verwendet, um auf den Text des Textfelds zuzugreifen.
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            appBar: null,
            body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Username',
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      obscureText: true,
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Password',
                      ),
                    ),
                  ),
                  Center(
                      child: ElevatedButton(
                        child: const Text("Login"),
                        onPressed: _tryLogin,
                      )
                  ),
                  Center(
                      child: ElevatedButton(
                        child: const Text("Register"),
                        onPressed: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegisterScreen())
                          );
                        },
                      )
                  )
                ]
            )
        ),
    );
  }

  /// Generiert aus den Daten der Textfelder ein Objekt der Klasse [UserData].
  /// Das Objekt wird anschließend an das Backend gesendet und der Rückgabewert
  /// evaluiert.
  void _tryLogin() async {
    final user = LoginData(
      "",
      _usernameController.text,
      _passwordController.text
    );
    var token = await BackendAPI().loginUser(user);
    token = token.replaceAll("\"", "");
    if (token == "Login-Error!"){
      var snackBar = SnackBar(
        content: Text(token),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      StorageManager.saveData("token", token);
      StorageManager.saveData("username", user.username);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ContentScreen())
      );
    }
  }
}