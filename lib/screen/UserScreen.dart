import 'package:flutter/material.dart';
import 'package:mobileapplication1/api/BackendAPI.dart';
import 'package:mobileapplication1/utils/StoreManager.dart';
import 'package:mobileapplication1/widgets/ContentList.dart';

import '../enum/Gender.dart';
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
  late Future<List<ContentData>> _userContent;
  late Future<List<String>> _userFriends;

  @override
  void initState() {
    userData = widget.userData;
    _userContent = _getContent();
    _userFriends = _getFriendsList();
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
                      height: MediaQuery.of(context).size.height-255,
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
                          FutureBuilder(
                            future: _userContent,
                            builder: (context, snapshot) {
                              return RefreshIndicator(
                                onRefresh: _refreshList,
                                child: _getUserContent(snapshot),
                              );
                            },
                          ),
                          FutureBuilder(
                            future: _userFriends,
                            builder: (context, snapshot) {
                              return RefreshIndicator(
                                onRefresh: _refreshFriendList,
                                child: _getFriendList(snapshot),
                              );
                            },
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

  _getUserContent(snapshot) {
    if (snapshot.connectionState != ConnectionState.done) {
      return const Center(
          child: CircularProgressIndicator()
      );
    }
    if(snapshot.hasData) {
      return ContentList(
        content: snapshot.data as List<ContentData>,
        showEditingOptions: true,
      );
    } else {
      return const Center(
          child: CircularProgressIndicator()
      );
    }
  }

  _getFriendList(snapshot){
    if (snapshot.connectionState != ConnectionState.done) {
      return const Center(
          child: CircularProgressIndicator()
      );
    }
    if(snapshot.hasData) {
      final friendsList = snapshot.data as List<String>;
      return ListView(
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
      );
    } else {
      return const Center(
          child: CircularProgressIndicator()
      );
    }
  }

  Future<void> _refreshList() async {
    var newContent = await _getContent();
    setState(() {
      _userContent = Future.value(newContent);
    });
  }

  Future<void> _refreshFriendList() async {
    var newFriends = await _getFriendsList();
    setState(() {
      _userFriends = Future.value(newFriends);
    });
  }

  Future<List<String>> _getFriendsList() async {
    final token = await StorageManager.readData("token");
    final username = await StorageManager.readData("username");
    return await BackendAPI().getFriendsList(token, username);
  }

  Future<List<ContentData>> _getContent() async {
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
    return list;
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