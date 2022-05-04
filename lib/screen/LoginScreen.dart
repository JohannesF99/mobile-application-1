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

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

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

  void tryLogin() async {
    final user = UserData(
      "",
      usernameController.text,
      passwordController.text
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