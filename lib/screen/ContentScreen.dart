import 'package:flutter/material.dart';
import 'package:mobileapplication1/api/BackendAPI.dart';
import 'package:mobileapplication1/model/UserData.dart';

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
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: const Text('Test'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ]
        ),
      ),
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.help,
              color: Colors.white,
            ),
            onPressed: () {
              showDialog(context: context, builder: (BuildContext context){
                return const AlertDialog(
                  title: Text("Über Die App"),
                  content: Text(
                  "Diese App ermöglicht Ihnen eine Account-Verwaltung!\n\n"
                  "\"Register\":\nErstellen Sie ein Konto!\n\n"
                  "\"Login\":\n Melden Sie sich auf Ihrem Konto an!\n\n"
                  "\"Logout\":\n Melden Sie sich von Ihrem Konto ab!"),
                );
              });
            },
          )
        ],
      ),
      body: Center(
          child: Column(
            children: [
              ElevatedButton(
                child: const Text("Register"),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen())
                  );
                },
              ),
              ElevatedButton(
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
              ElevatedButton(
                child: const Text("Logout"),
                onPressed: () async {
                  var result = await BackendAPI().logoutUser(bearerToken);
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
