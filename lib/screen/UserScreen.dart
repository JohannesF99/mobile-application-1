import 'package:flutter/material.dart';
import 'package:mobileapplication1/api/BackendAPI.dart';
import 'package:mobileapplication1/utils/StoreManager.dart';

import '../enum/Gender.dart';
import '../enum/Interaction.dart';
import '../model/ContentData.dart';
import '../model/UserData.dart';
import '../utils/NoOverflowBehavior.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key, required this.userData}) : super(key: key);

  final UserData userData;
  
  @override
  State<UserScreen> createState() => _UserScreen();
}

class _UserScreen extends State<UserScreen>{

  // Variablen für den Info-Tab
  final _nameController = TextEditingController();
  final _vornameController = TextEditingController();
  bool showEdit = false;
  late UserData userData;
  // Variablen für den Post-Tab
  List<ContentData> userContent = [];
  final _changeController = TextEditingController();
  var _index = 0;
  //Variablen für den Freunde-Tab
  List<String> friendsList = [];

  @override
  void initState() {
    userData = widget.userData;
    _getContent();
    _getFriendsList();
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _nameController.dispose();
    _vornameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text("Benutzer"),
          actions: getEditOrSaveButton(),
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        body: ScrollConfiguration(
          behavior: NoOverflowBehavior(),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    const Image(
                      image: AssetImage('images/settings.png'),
                      fit: BoxFit.cover,
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
                DefaultTabController(
                  length: 3,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        color: Theme.of(context).appBarTheme.backgroundColor,
                        child: TabBar(
                            labelColor: Theme.of(context).iconTheme.color,
                            indicatorColor: Theme.of(context).iconTheme.color,
                            unselectedLabelColor: Theme.of(context).appBarTheme.titleTextStyle!.color,
                            tabs: const [
                              Tab(text: "Infos"),
                              Tab(text: "Posts"),
                              Tab(text: "Freunde"),
                            ]
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height-260,
                        child: TabBarView(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text("Username:"),
                                      Text("E-Mail:"),
                                      Text("Name:"),
                                      Text("Vorname:"),
                                      Text("Geschlecht:"),
                                      Text("Geburtstag:"),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(userData.username),
                                      Text(userData.email),
                                      getTextOrEditWidget(userData.name ?? "null", _nameController),
                                      getTextOrEditWidget(userData.vorname ?? "null", _vornameController),
                                      getTextOrDropdownWidget(userData.gender.name),
                                      getTextOrDatePickerWidget(userData.getBirthday()),
                                    ],
                                  ),
                                ],
                              ),
                              Center(
                                child: SizedBox(
                                  height: MediaQuery.of(context).size.height/3, // card height
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
                                                            userData.username,
                                                            style: Theme.of(context).textTheme.headline6,
                                                          ),
                                                          const Spacer(),
                                                          Text(_getPostTime(userContent[i].created)),
                                                        ],
                                                      ),
                                                      const Divider(),
                                                      Text(
                                                        userContent[i].caption,
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
                                                        final contentId = userContent[i].contentId!;
                                                        if (userContent[i].interactionData!.myInteraction == Interaction.Dislike || userContent[i].interactionData!.myInteraction == Interaction.None) {
                                                          final result = await BackendAPI().likeContent(token, username, contentId);
                                                          if (result && userContent[i].interactionData!.myInteraction == Interaction.Dislike) {
                                                            userContent[i].interactionData!.likes++;
                                                            userContent[i].interactionData!.dislikes--;
                                                            userContent[i].interactionData!.myInteraction = Interaction.Like;
                                                          } else if (result && userContent[i].interactionData!.myInteraction == Interaction.None) {
                                                            userContent[i].interactionData!.likes++;
                                                            userContent[i].interactionData!.myInteraction = Interaction.Like;
                                                          }
                                                        } else {
                                                          final result = await BackendAPI().removeInteraction(token, username, contentId);
                                                          if (result && userContent[i].interactionData!.myInteraction == Interaction.Dislike) {
                                                            userContent[i].interactionData!.dislikes--;
                                                            userContent[i].interactionData!.myInteraction = Interaction.None;
                                                          } else if (result && userContent[i].interactionData!.myInteraction == Interaction.Like) {
                                                            userContent[i].interactionData!.likes--;
                                                            userContent[i].interactionData!.myInteraction = Interaction.None;
                                                          }
                                                        }
                                                        setState(() {});
                                                      },
                                                      icon: const Icon(Icons.keyboard_arrow_up),
                                                      color: _getColor(i, Interaction.Like),
                                                    ),
                                                    Text("${userContent[i].interactionData!.likes - userContent[i].interactionData!.dislikes}"),
                                                    IconButton(
                                                      onPressed: () async {
                                                        final token = await StorageManager.readData("token");
                                                        final username = await StorageManager.readData("username");
                                                        final contentId = userContent[i].contentId!;
                                                        if (userContent[i].interactionData!.myInteraction == Interaction.Like || userContent[i].interactionData!.myInteraction == Interaction.None) {
                                                          final result = await BackendAPI().dislikeContent(token, username, contentId);
                                                          if (result && userContent[i].interactionData!.myInteraction == Interaction.Like) {
                                                            userContent[i].interactionData!.likes--;
                                                            userContent[i].interactionData!.dislikes++;
                                                            userContent[i].interactionData!.myInteraction = Interaction.Dislike;
                                                          } else if (result && userContent[i].interactionData!.myInteraction == Interaction.None) {
                                                            userContent[i].interactionData!.dislikes++;
                                                            userContent[i].interactionData!.myInteraction = Interaction.Dislike;
                                                          }
                                                        } else {
                                                          final result = await BackendAPI().removeInteraction(token, username, contentId);
                                                          if (result && userContent[i].interactionData!.myInteraction == Interaction.Dislike) {
                                                            userContent[i].interactionData!.dislikes--;
                                                            userContent[i].interactionData!.myInteraction = Interaction.None;
                                                          } else if (result && userContent[i].interactionData!.myInteraction == Interaction.Like) {
                                                            userContent[i].interactionData!.likes--;
                                                            userContent[i].interactionData!.myInteraction = Interaction.None;
                                                          }
                                                        }
                                                        setState(() {});
                                                      },
                                                      icon: const Icon(Icons.keyboard_arrow_down),
                                                      color: _getColor(i, Interaction.Dislike),
                                                    ),
                                                    const Spacer(),
                                                    IconButton(
                                                      icon: const Icon(Icons.edit),
                                                      onPressed: () {
                                                        _changeController.text = userContent[i].caption;
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return AlertDialog(
                                                              title: const Text("Inhalt ändern:"),
                                                              content: TextFormField(
                                                                controller: _changeController,
                                                              ),
                                                              actions: [
                                                                TextButton(
                                                                  child: const Text('Close'),
                                                                  onPressed: () {
                                                                    Navigator.pop(context);
                                                                  },
                                                                ),
                                                                TextButton(
                                                                  child: const Text('Send'),
                                                                  onPressed: () async {
                                                                    final token = await StorageManager.readData("token");
                                                                    final username = await StorageManager.readData("username");
                                                                    BackendAPI().changeContent(token, username, userContent[i].contentId!, _changeController.text)
                                                                        .then((success) { 
                                                                          if(success) userContent[i].caption = _changeController.text; 
                                                                        });
                                                                    Navigator.pop(context);
                                                                  },
                                                                ),
                                                              ],
                                                            );
                                                          }
                                                        );
                                                      },
                                                    ),
                                                    IconButton(
                                                        onPressed: () async {
                                                          final token = await StorageManager.readData("token");
                                                          final username = await StorageManager.readData("username");
                                                          final contentId = userContent[i].contentId!;
                                                          final result = await BackendAPI().deleteUserContent(token, username, contentId);
                                                          if (result) {
                                                            setState(() {
                                                              userContent.removeAt(i);
                                                              _index--;
                                                            });
                                                          }
                                                        },
                                                        icon: const Icon(Icons.delete_sweep_outlined)
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
                              ListView(
                                padding: const EdgeInsets.all(0),
                                children: friendsList.map((e) =>
                                  Card(
                                    child: Container(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Row(
                                        children: [
                                          Text(e),
                                          const Spacer(),
                                          IconButton(
                                              onPressed: () async {
                                                final token = await StorageManager.readData("token");
                                                final username = await StorageManager.readData("username");
                                                BackendAPI().removeFriend(token, username, e);
                                                friendsList.remove(e);
                                                setState(() {});
                                              },
                                              icon: const Icon(Icons.cancel)
                                          )
                                        ],
                                      ),
                                    )
                                  ),
                                ).toList(),
                              ),
                            ]
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }

  _getFriendsList() async {
    final token = await StorageManager.readData("token");
    final username = await StorageManager.readData("username");
    friendsList = await BackendAPI().getFriendsList(token, username);
  }

  _getContent() async {
    final token = await StorageManager.readData("token");
    final username = await StorageManager.readData("username");
    final list = await BackendAPI().getUserContent(token, username);
    for (var element in list) {
      element.interactionData = await BackendAPI().getInteractionDataForContent(
          token,
          username,
          element.contentId!
      );
    }
    setState(() {
      userContent = list;
    });
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

  Color _getColor(int i, Interaction interaction) {
    if (interaction == userContent[i].interactionData!.myInteraction){
      return Theme.of(context).primaryColor;
    }
    return Theme.of(context).backgroundColor;
  }

  Widget getTextOrEditWidget(String value, TextEditingController textController){
    if(showEdit) {
      return SizedBox(
        width: 50,
        child: TextField(
          controller: textController,
          decoration: InputDecoration(
            border: const UnderlineInputBorder(),
            hintText: value,
          ),
        ),
      );
    } else {
      return Text(value);
    }
  }

  Widget getTextOrDropdownWidget(String value){
    if(showEdit) {
      return SizedBox(
        width: 100,
        child: DropdownButton<Gender>(
          value: Gender.values.byName(value),
          items: Gender.values.map((listValue) {
            return DropdownMenuItem<Gender>(
              value: listValue,
              child: Text(listValue.name),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              userData.gender = newValue!;
            });
          },
        )
      );
    } else {
      return Text(value);
    }
  }

  Widget getTextOrDatePickerWidget(String value){
    if(showEdit) {
      return SizedBox(
          width: 100,
          child: IconButton(
            icon: const Icon(
              Icons.calendar_today,
            ),
            onPressed: () async {
              final DateTime? selected = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
              );
              if (selected != null && selected != userData.birthday) {
                setState(() {
                  userData.birthday = selected;
                });
              }
            },
          )
      );
    } else {
      return Text(value);
    }
  }

  List<Widget> getEditOrSaveButton(){
    if (showEdit) {
      return [
        IconButton(
          icon: const Icon(
            Icons.cancel_outlined,
          ),
          onPressed: () async {
            _nameController.clear();
            _vornameController.clear();
            var token = await StorageManager.readData("token") as String;
            userData = await BackendAPI().getUserData(token, userData.username);
            setState(() {
              showEdit = !showEdit;
            });
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.save,
          ),
          onPressed: () async {
            var token = await StorageManager.readData("token") as String;
            var editedData = UserData(
              userData.username,
              userData.email,
              _nameController.text,
              _vornameController.text,
              userData.gender,
              userData.birthday.toString(),
            );
            var response = await BackendAPI().sendNewUserData(
              token,
              userData.username,
              editedData
            );
            if (response != 200) {
              Navigator.pop(context);
              var snackBar = const SnackBar(
                content: Text("Error bei Info-Update!"),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
            var newData = await BackendAPI().getUserData(token, userData.username);
            setState(() {
              userData = newData;
              showEdit = !showEdit;
            });
          },
        ),
      ];
    } else {
      return [
        IconButton(
          icon: const Icon(
            Icons.edit,
          ),
          onPressed: () {
            setState(() {
              showEdit = !showEdit;
            });
          },
        )
      ];
    }
  }
}