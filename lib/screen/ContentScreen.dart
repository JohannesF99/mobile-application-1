import 'package:flutter/material.dart';
import 'package:mobileapplication1/api/BackendAPI.dart';
import 'package:mobileapplication1/model/ContentData.dart';
import 'package:mobileapplication1/model/LoginData.dart';

import '../main.dart';
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
  var _index = 0;
  List<ContentData> userContent = [];

  @override
  void initState() {
    _getContent();
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
              Icons.download,
            ),
            onPressed: _getContent,
          ),
          IconButton(
            icon: const Icon(
              Icons.help_outline,
            ),
            onPressed: () {
              showDialog(context: context, builder: (BuildContext context) =>
              const AlertDialog(
                  title: Text("Über Die App"),
                  content: Text(
                  "Diese App ermöglicht Ihnen eine Account-Verwaltung!\n\n"
                  "\"Register\":\nErstellen Sie ein Konto!\n\n"
                  "\"Login\":\n Melden Sie sich auf Ihrem Konto an!\n\n"
                  "\"Logout\":\n Melden Sie sich von Ihrem Konto ab!"),
                )
              );
            },
          )
        ],
      ),
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 100, // card height
          child: PageView.builder(
            itemCount: userContent.length,
            controller: PageController(viewportFraction: 0.7),
            onPageChanged: (int index) => setState(() => _index = index),
            reverse: true,
            itemBuilder: (_, i) {
              return Transform.scale(
                scale: i == _index ? 1 : 0.9,
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Center(
                    child: Text(
                      userContent[i].caption,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.plus_one),
        onPressed: () async {
          final token = await StorageManager.readData("token");
          final username = await StorageManager.readData("username");
          final content = ContentData("caption");
          BackendAPI().sendNewPost(token, username, content).then((value) =>
              _getContent()
          );
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

  _getContent() async {
    final token = await StorageManager.readData("token");
    final username = await StorageManager.readData("username");
    final list = await BackendAPI().getUserContent(token, username);
    setState(() {
      userContent = list;
    });
  }
}
