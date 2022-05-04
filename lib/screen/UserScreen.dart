import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobileapplication1/api/BackendAPI.dart';
import 'package:mobileapplication1/model/UserData.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);
  // that it has a State object (defined below) that contains fields that affect
  // This class is the configuration for the state. It holds the values (in this

  // how it looks.
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are

  // always marked "final".

  @override
  State<UserScreen> createState() => _UserScreen();
}

class _UserScreen extends State<UserScreen> {

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
        appBar: AppBar(
          title: const Text("Benutzer"),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.refresh,
              ),
              onPressed: () {
              },
            )
          ],
          automaticallyImplyLeading: false,
        ),
        body: const Text("Hello"),
    );
  }
}