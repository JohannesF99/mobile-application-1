import 'package:flutter/material.dart';
import 'package:mobileapplication1/api/BackendAPI.dart';

import 'LoginScreen.dart';
import 'RegisterScreen.dart';
import '../utils/StoreManager.dart';

class ContentScreen extends StatefulWidget {
  const ContentScreen({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {

  bool darkMode = false;

  @override
  void initState() {
    StorageManager.readData("token").then((value) async {
      if (value == null){
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen())
        );
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Theme.of(context).drawerTheme.backgroundColor,
        child: ListView(
          children: [
            const DrawerHeader(
              padding: EdgeInsets.all(0),
              child: Image(
                image: AssetImage('images/settings.png'),
                fit: BoxFit.cover,
              ),
            ),
            ListTile(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.logout),
                  Text('Logout'),
                ],
              ),
              onTap: () async {
                StorageManager.readData("token").then((value) async {
                  BackendAPI().logoutUser(value);
                });
                StorageManager.deleteData("token");
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen())
                );
              },
            ),
            ListTile(
              enableFeedback: false,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.brightness_6),
                  const Text('Dark Mode'),
                  const Spacer(),
                  Switch(
                    activeColor: Colors.black,
                      value: darkMode,
                      onChanged: (value){
                        setState(() {
                          darkMode = value;
                        });
                      })
                ],
              ),
            ),
          ]
        ),
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
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
      body: const Center(
          child: Text("Hallo!")
      ),
    );
  }
}
