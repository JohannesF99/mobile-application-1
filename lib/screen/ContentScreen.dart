import 'package:flutter/material.dart';
import 'package:mobileapplication1/api/BackendAPI.dart';
import 'package:mobileapplication1/model/LoginData.dart';
import 'package:mobileapplication1/widgets/ContentList.dart';

import '../main.dart';
import '../model/ContentData.dart';
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
                ).whenComplete(() {
                  setState(() {});
                });
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
                final _passwordController = TextEditingController();
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
                          controller: _passwordController,
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
                                _passwordController.text
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
                    activeColor: Theme.of(context).iconTheme.color,
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
        elevation: 6,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(10)
            ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: IconButton(
          icon: const Icon(Icons.grid_on_outlined),
          enableFeedback: false,
          onPressed: () {

          },
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.search,
            ),
            onPressed: (){
              showDialog(
                  context: context,
                  builder: (context) {
                    final _friendController = TextEditingController();
                    return AlertDialog(
                      title: const Text("Freund hinzufügen:"),
                      content: TextFormField(
                        controller: _friendController,
                      ),
                      actions: [
                        TextButton(
                            child: const Text('Close'),
                            onPressed: () {
                              Navigator.pop(context);
                              _friendController.clear();
                            },
                        ),
                        TextButton(
                          child: const Text('Add Friend'),
                          onPressed: () async {
                            final token = await StorageManager.readData("token");
                            final username = await StorageManager.readData("username");
                            BackendAPI().addFriend(token, username, _friendController.text)
                                .whenComplete(() {
                                  setState(() {});
                            });
                            Navigator.pop(context);
                            _friendController.clear();
                          },
                        ),
                      ],
                    );
                  },
              );
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _getContent(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
                child: CircularProgressIndicator()
            );
          }
          if(snapshot.hasData) {
            return ContentList(
              content: snapshot.data as List<ContentData>,
            );
          } else {
            return const Center(
                child: CircularProgressIndicator()
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.plus_one),
        onPressed: () async {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateScreen())
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

  Future<List<ContentData>> _getContent() async {
    final token = await StorageManager.readData("token");
    final username = await StorageManager.readData("username");
    final list = await BackendAPI().getFriendsContent(token, username);
    for (var element in list) {
      element.interactionData = await BackendAPI().getInteractionDataForContent(
          token,
          username,
          element.contentId!
      );
    }
    return list;
  }
}