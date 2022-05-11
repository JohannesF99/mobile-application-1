import 'package:flutter/material.dart';
import 'package:mobileapplication1/screen/RegisterScreen.dart';

import '../api/BackendAPI.dart';
import '../model/UserData.dart';
import '../utils/StoreManager.dart';
import 'ContentScreen.dart';

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
                          var result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegisterScreen())
                          );
                          StorageManager.saveData("token", result);
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
    final user = UserData(
      "",
      _usernameController.text,
      _passwordController.text
    );
    var token = await BackendAPI().loginUser(user);
    if (token == "Login-Error!"){
      var snackBar = SnackBar(
        content: Text(token),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      StorageManager.saveData("token", token);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ContentScreen())
      );
    }
  }
}