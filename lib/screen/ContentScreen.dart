import 'package:flutter/material.dart';
import 'package:mobileapplication1/api/BackendAPI.dart';
import 'package:mobileapplication1/model/LoginData.dart';

import '../main.dart';
import 'CreateScreen.dart';
import 'LoginScreen.dart';
import '../utils/StoreManager.dart';
import 'UserScreen.dart';

/// Die root-Seite der Anwendung. Enthält alle Routen zu anderen Seiten.
/// Umfasst Routen um den Logout und den DarkMode zu steuern.
class ContentScreen extends StatefulWidget {
  const ContentScreen({Key? key}) : super(key: key);

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {

  /// Beschreibt den Modus des App-Themas.
  bool _darkMode = false;
  final passwordController = TextEditingController();
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Theme.of(context).drawerTheme.backgroundColor,
        child: ListView(
          children: [
            Stack(
              children: [
                const DrawerHeader(
                  padding: EdgeInsets.all(0),
                  child: Image(
                    image: AssetImage('images/settings.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  left: 10,
                  bottom: 20,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(200.0),
                    child: const Image(
                      width: 100,
                      image: AssetImage('images/profilbild.jpg'),
                    ),
                  ),
                )
              ],
            ),
            ListTile(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person),
                  Text(
                    'Profile',
                    style:  TextStyle(color: Theme.of(context).iconTheme.color),
                  ),
                ],
              ),
              onTap: () async {
                Navigator.pop(context);
                var token = await StorageManager.readData("token");
                var username = await StorageManager.readData("username");
                var userData = await BackendAPI().getUserData(token, username);
                Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => UserScreen(userData: userData),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(
                        opacity:animation,
                        child: child,
                      ),
                    )
                );
              },
            ),
            ListTile(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.logout),
                  Text(
                      'Logout',
                      style:  TextStyle(color: Theme.of(context).iconTheme.color),
                  ),
                ],
              ),
              onTap: _tryLogout,
            ),
            ListTile(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.delete_forever),
                  Text(
                    'Delete Account',
                    style:  TextStyle(color: Theme.of(context).iconTheme.color),
                  ),
                ],
              ),
              onTap: (){
                Navigator.pop(context);
                showDialog(context: context, builder: (BuildContext context) =>
                    AlertDialog(
                      title: const Text("Account löschen?"),
                      content: const Text("Sie sind im Begriff ihren Account zu löschen!"),
                      actions: [
                        TextField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Password',
                          ),
                          controller: passwordController,
                          obscureText: true,
                        ),
                        TextButton(
                          child: const Text("OK"),
                          onPressed: () async {
                            var username = await StorageManager.readData("username");
                            var bearerToken = await StorageManager.readData("token");
                            var user = LoginData(
                                "",
                                username,
                                passwordController.text
                            );
                            if (await BackendAPI().deleteUser(user, bearerToken)){
                              StorageManager.clearAll();
                              Navigator.pop(context);
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LoginScreen())
                              );
                            } else {
                              var snackBar = const SnackBar(
                                content: Text("Fehler beim Löschen!"),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            }
                          },
                        )
                      ],
                    )
                );
              },
            ),
            ListTile(
              enableFeedback: false,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.brightness_6),
                  Text(
                    'Dark Mode',
                    style:  TextStyle(color: Theme.of(context).iconTheme.color),
                  ),
                  const Spacer(),
                  Switch(
                    activeColor: Colors.black,
                    value: _darkMode,
                    onChanged: (value){
                      _darkMode = value;
                      _setThemeMode(value);
                    }
                  )
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
              Icons.search,
            ),
            onPressed: (){

            },
          ),
        ],
      ),
      body: null,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.plus_one),
        onPressed: () async {
          final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateScreen())
          );
          if (result) {
            //_getContent();
          }
        },
      ),
    );
  }

  /// Lädt den Login-Token aus den Shared Preferences und versucht den Benutzer
  /// damit abzumelden.
  /// Anschließend wird der gesammte Speicher der Shared Preferences gelöscht
  /// und der Navigator-Stack aktualisiert.
  void _tryLogout() async {
    final value = await StorageManager.readData("token");
    BackendAPI().logoutUser(value);
    StorageManager.clearAll();
    Navigator.pop(context);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen())
    );
  }

  /// Übernimmt den aktuellen Modus und ändert das Thema.
  _setThemeMode(bool darkMode) {
    if (darkMode) {
      MyApp.of(context)!.changeTheme(ThemeMode.dark);
    } else {
      MyApp.of(context)!.changeTheme(ThemeMode.light);
    }
  }
}