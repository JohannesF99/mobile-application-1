import 'package:flutter/material.dart';
import 'package:mobileapplication1/api/BackendAPI.dart';
import 'package:mobileapplication1/model/UserData.dart';

/// Beschreibt die Registration. Nach erfolgreicher Registration wird
/// zurück auf die Login-Seite verwiesen.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreen();
}

class _RegisterScreen extends State<RegisterScreen> {

  /// Controller für das Textfeld der E-Mail.
  /// Wird verwendet, um auf den Text des Textfelds zuzugreifen.
  final _emailController = TextEditingController();

  /// Controller für das Textfeld des Benutzernamens.
  /// Wird verwendet, um auf den Text des Textfelds zuzugreifen.
  final _usernameController = TextEditingController();

  /// Controller für das Textfeld des Passworts.
  /// Wird verwendet, um auf den Text des Textfelds zuzugreifen.
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 300,
            child: TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'E-Mail',
              ),
            ),
          ),
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
                child: const Text("Register"),
                onPressed: () async {
                  var user = UserData(
                      _emailController.text,
                      _usernameController.text,
                      _passwordController.text
                  );
                  var message = await BackendAPI().registerUser(user);
                  var snackBar = SnackBar(
                    content: Text(message),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  if (message != "Register-Error!") {
                    Navigator.pop(context);
                  }
                },
              )
          )
        ]
      )
    );
  }
}