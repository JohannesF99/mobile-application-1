import 'package:flutter/material.dart';

import 'LoginScreen.dart';
import 'RegisterScreen.dart';

class ContentScreen extends StatefulWidget {
  const ContentScreen({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {

  String bearerToken = 'Bearer Token';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: Column(
            children: [
              TextButton(
                child: const Text("Register"),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen())
                  );
                },
              ),
              TextButton(
                child: const Text("Login"),
                onPressed: () async {
                  var result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen())
                  );
                  setState(() {
                    bearerToken = result;
                  });
                },
              ),
              Text(bearerToken),
            ],
          )
      ),
    );
  }
}
