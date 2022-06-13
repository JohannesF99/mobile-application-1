import 'package:flutter/material.dart';
import 'package:mobileapplication1/api/BackendAPI.dart';
import 'package:mobileapplication1/utils/StoreManager.dart';
import 'package:mobileapplication1/widgets/ContentList.dart';

import '../model/ContentData.dart';
import '../model/UserData.dart';
import '../utils/NoOverflowBehavior.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({Key? key, required this.userData}) : super(key: key);

  final UserData userData;

  @override
  State<UserInfoScreen> createState() => _UserInfoScreen();
}

class _UserInfoScreen extends State<UserInfoScreen>{

  late UserData _userData;
  late Future<List<ContentData>> _userContent;
  late Future<Map<String, bool>> _userFriends;

  @override
  void initState() {
    _userData = widget.userData;
    _userContent = _getContent();
    _userFriends = _getFriendsList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(_userData.username),
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
                                  Text(_userData.username),
                                  Text(_userData.email),
                                  Text(_userData.name ?? "null"),
                                  Text(_userData.vorname ?? "null"),
                                  Text(_userData.gender.name),
                                  Text(_userData.getBirthday()),
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
        showEditingOptions: false,
        showVoteOptions: true,
        showUserNameLink: false,
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
      final friendsList = snapshot.data as Map<String, bool>;
      return ListView(
        padding: const EdgeInsets.all(0),
        children: friendsList.entries.map((e) =>
            Card(
                child: Container(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    children: [
                      InkWell(
                        child: Text(
                          e.key,
                        ),
                        onTap: () => _showProfile(e.key),
                      ),
                      const Spacer(),
                      _getAddOrRemoveButton(e)
                    ],
                  ),
                )
            )
        ).toList()
      );
    } else {
      return const Center(
          child: CircularProgressIndicator()
      );
    }
  }

  _showProfile(String username) async {
    final token = await StorageManager.readData("token");
    final userData = await BackendAPI().getUserData(token, username);
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserInfoScreen(userData: userData))
    );
  }

  _getAddOrRemoveButton(MapEntry<String, bool> entry) {
    if (entry.value) {
      return IconButton(
          onPressed: () async {
            final token = await StorageManager.readData("token");
            final username = await StorageManager.readData("username");
            BackendAPI().removeFriend(token, username, entry.key)
                .whenComplete(() => _refreshFriendList());
          },
          icon: const Icon(Icons.cancel)
      );
    } else {
      return IconButton(
          onPressed: () async {
            final token = await StorageManager.readData("token");
            final username = await StorageManager.readData("username");
            BackendAPI().addFriend(token, username, entry.key)
                .whenComplete(() => _refreshFriendList());
          },
          icon: const Icon(Icons.add)
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

  Future<Map<String, bool>> _getFriendsList() async {
    final token = await StorageManager.readData("token");
    final username = _userData.username;
    final loggedInUsername = await StorageManager.readData("username");
    final loggedInFriendsList = await BackendAPI().getFriendsList(token, loggedInUsername);
    final friendList = await BackendAPI().getFriendsList(token, username);
    friendList.remove(loggedInUsername);
    Map<String, bool> map = {};
    for (var element in friendList) {
      map[element] = loggedInFriendsList.contains(element);
    }
    return map;
  }

  Future<List<ContentData>> _getContent() async {
    final token = await StorageManager.readData("token");
    final username = _userData.username;
    final loggedInUsername = await StorageManager.readData("username");
    final list = await BackendAPI().getUserContent(token, username);
    for (var element in list) {
      element.interactionData = await BackendAPI().getInteractionDataForContent(
          token,
          loggedInUsername,
          element.contentId!
      );
    }
    return list;
  }
}