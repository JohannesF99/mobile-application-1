import 'package:flutter/material.dart';
import 'package:mobileapplication1/screen/RegisterScreen.dart';

import '../api/BackendAPI.dart';
import '../model/LoginData.dart';
import '../utils/StoreManager.dart';
import 'ContentScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    usernameController.dispose();
    passwordController.dispose();
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
                      controller: usernameController,
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
                      controller: passwordController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Password',
                      ),
                    ),
                  ),
                  Center(
                      child: ElevatedButton(
                        child: const Text("Login"),
                        onPressed: tryLogin,
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

  void tryLogin() async {
    final user = LoginData(
      "",
      usernameController.text,
      passwordController.text
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