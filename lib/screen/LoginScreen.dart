import 'package:flutter/material.dart';

import '../api/BackendAPI.dart';
import '../model/UserData.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  // that it has a State object (defined below) that contains fields that affect
  // This class is the configuration for the state. It holds the values (in this

  // how it looks.
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are

  // always marked "final".

  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {

  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: null,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 300,
            child: TextField(
              controller: emailController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'E-Mail',
              ),
            ),
          ),
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
              controller: passwordController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Password',
              ),
            ),
          ),
          Center(
              child: TextButton(
                child: const Text("Login"),
                onPressed: () async {
                  var user = UserData(
                      emailController.text,
                      usernameController.text,
                      passwordController.text);
                  var token = await BackendAPI().loginUser(user);
                  Navigator.pop(context, token);
                },
              )
          )
        ]
      )
    );
  }
}