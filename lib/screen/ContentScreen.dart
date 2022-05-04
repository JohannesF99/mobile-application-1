import 'package:flutter/material.dart';
import 'package:mobileapplication1/api/BackendAPI.dart';

import '../main.dart';
import 'LoginScreen.dart';
import '../utils/StoreManager.dart';

class ContentScreen extends StatefulWidget {
  const ContentScreen({Key? key}) : super(key: key);

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {

  bool darkMode = false;

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
                StorageManager.clearAll();
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
                        darkMode = value;
                        _setThemeMode(value);
                      })
                ],
              ),
            ),
          ]
        ),
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const Text("Mobile Application 1"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.help_outline,
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

  _setThemeMode(bool darkMode) {
    if (darkMode) {
      MyApp.of(context)!.changeTheme(ThemeMode.dark);
    } else {
      MyApp.of(context)!.changeTheme(ThemeMode.light);
    }
  }
}
