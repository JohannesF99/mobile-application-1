import 'package:flutter/material.dart';
import 'package:mobileapplication1/api/BackendAPI.dart';
import 'package:mobileapplication1/model/LoginData.dart';
import 'package:mobileapplication1/utils/NoOverflowBehavior.dart';

import '../enum/Interaction.dart';
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
  final _passwordController = TextEditingController();
  final _friendController = TextEditingController();
  List<ContentData> friendContent = [];
  var _index = 0;

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
                ).whenComplete(() => _getContent());
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
              showDialog(
                  context: context,
                  builder: (context) {
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
                            },
                        ),
                        TextButton(
                          child: const Text('Add Friend'),
                          onPressed: () async {
                            final token = await StorageManager.readData("token");
                            final username = await StorageManager.readData("username");
                            BackendAPI().addFriend(token, username, _friendController.text)
                                .whenComplete(() => _getContent());
                            Navigator.pop(context);
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
      body: ScrollConfiguration(
        behavior: NoOverflowBehavior(),
        child: Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height/3, // card height
            child: PageView.builder(
              itemCount: friendContent.length,
              controller: PageController(viewportFraction: 0.7),
              onPageChanged: (int index) => setState(() => _index = index),
              reverse: true,
              itemBuilder: (_, i) {
                return Transform.scale(
                  scale: i == _index ? 1 : 0.9,
                  child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      friendContent[i].userData!.username,
                                      style: Theme.of(context).textTheme.headline6,
                                    ),
                                    const Spacer(),
                                    Text(
                                        _getPostTime(friendContent[i].created)
                                    )
                                  ],
                                ),
                                const Divider(),
                                Text(
                                  friendContent[i].caption,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 6,
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () async {
                                  final token = await StorageManager.readData("token");
                                  final username = await StorageManager.readData("username");
                                  final contentId = friendContent[i].contentId!;
                                  if (friendContent[i].interactionData!.myInteraction == Interaction.Dislike || friendContent[i].interactionData!.myInteraction == Interaction.None) {
                                    final result = await BackendAPI().likeContent(token, username, contentId);
                                    if (result && friendContent[i].interactionData!.myInteraction == Interaction.Dislike) {
                                      friendContent[i].interactionData!.likes++;
                                      friendContent[i].interactionData!.dislikes--;
                                      friendContent[i].interactionData!.myInteraction = Interaction.Like;
                                    } else if (result && friendContent[i].interactionData!.myInteraction == Interaction.None) {
                                      friendContent[i].interactionData!.likes++;
                                      friendContent[i].interactionData!.myInteraction = Interaction.Like;
                                    }
                                  } else {
                                    final result = await BackendAPI().removeInteraction(token, username, contentId);
                                    if (result && friendContent[i].interactionData!.myInteraction == Interaction.Dislike) {
                                      friendContent[i].interactionData!.dislikes--;
                                      friendContent[i].interactionData!.myInteraction = Interaction.None;
                                    } else if (result && friendContent[i].interactionData!.myInteraction == Interaction.Like) {
                                      friendContent[i].interactionData!.likes--;
                                      friendContent[i].interactionData!.myInteraction = Interaction.None;
                                    }
                                  }
                                  setState(() {});
                                },
                                icon: const Icon(Icons.keyboard_arrow_up),
                                color: _getColor(i, Interaction.Like),
                              ),
                              Text("${friendContent[i].interactionData!.likes - friendContent[i].interactionData!.dislikes}"),
                              IconButton(
                                onPressed: () async {
                                  final token = await StorageManager.readData("token");
                                  final username = await StorageManager.readData("username");
                                  final contentId = friendContent[i].contentId!;
                                  if (friendContent[i].interactionData!.myInteraction == Interaction.Like || friendContent[i].interactionData!.myInteraction == Interaction.None) {
                                    final result = await BackendAPI().dislikeContent(token, username, contentId);
                                    if (result && friendContent[i].interactionData!.myInteraction == Interaction.Like) {
                                      friendContent[i].interactionData!.likes--;
                                      friendContent[i].interactionData!.dislikes++;
                                      friendContent[i].interactionData!.myInteraction = Interaction.Dislike;
                                    } else if (result && friendContent[i].interactionData!.myInteraction == Interaction.None) {
                                      friendContent[i].interactionData!.dislikes++;
                                      friendContent[i].interactionData!.myInteraction = Interaction.Dislike;
                                    }
                                  } else {
                                    final result = await BackendAPI().removeInteraction(token, username, contentId);
                                    if (result && friendContent[i].interactionData!.myInteraction == Interaction.Dislike) {
                                      friendContent[i].interactionData!.dislikes--;
                                      friendContent[i].interactionData!.myInteraction = Interaction.None;
                                    } else if (result && friendContent[i].interactionData!.myInteraction == Interaction.Like) {
                                      friendContent[i].interactionData!.likes--;
                                      friendContent[i].interactionData!.myInteraction = Interaction.None;
                                    }
                                  }
                                  setState(() {});
                                },
                                icon: const Icon(Icons.keyboard_arrow_down),
                                color: _getColor(i, Interaction.Dislike),
                              ),
                            ],
                          ),
                        ],
                      )
                  ),
                );
              },
            ),
          ),
        ),
      ),
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

  _getContent() async {
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
    setState(() {
      friendContent = list;
    });
  }

  Color _getColor(int i, Interaction interaction) {
    if (interaction == friendContent[i].interactionData!.myInteraction){
      return Theme.of(context).primaryColor;
    }
    return Theme.of(context).backgroundColor;
  }

  String _getPostTime(DateTime created) {
    final min = DateTime.now().difference(created).inMinutes;
    final h = min ~/ 60;
    final days = h ~/ 24;
    final mon = days ~/ 30;
    if (mon >= 1) {
      return "$mon Mo.";
    }
    if (days >= 1) {
      return "$days Tage";
    }
    if (h >= 1) {
      return "$h h";
    }
    if (min < 1) {
      return "Jetzt";
    }
    return "$min min";
  }
}