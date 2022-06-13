import 'package:flutter/material.dart';
import 'package:mobileapplication1/api/BackendAPI.dart';
import 'package:mobileapplication1/utils/StoreManager.dart';

import '../model/LikeDislikeList.dart';
import 'UserInfoScreen.dart';

class InteractionScreen extends StatefulWidget {
  const InteractionScreen({Key? key,
    required this.contentId,
    required this.friendList,
    required this.username
  }) : super(key: key);

  final int contentId;
  final List<String> friendList;
  final String username;

  @override
  State<StatefulWidget> createState() => _InteractionScreen();
}

class _InteractionScreen extends State<InteractionScreen> {

  late List<String> friendList;

  @override
  void initState() {
    friendList = widget.friendList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: FutureBuilder(
          future: _getInteractionLists(widget.contentId),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                  child: CircularProgressIndicator()
              );
            }
            if(snapshot.hasData) {
              final interactions = (snapshot.data as LikeDislikeList);
              return Scaffold(
                  appBar: AppBar(
                    bottom: TabBar(
                      tabs: [
                        Tab(text: "${interactions.likeList.length} Like(s)"),
                        Tab(text: "${interactions.dislikeList.length} Dislike(s)"),
                      ],
                    ),
                    title: Text('${interactions.dislikeList.length + interactions.likeList.length} Interaktion(en)'),
                  ),
                  body: TabBarView(
                    children: [
                      ListView.builder(
                          itemCount: interactions.likeList.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: Container(
                                height: 55,
                                padding: const EdgeInsets.only(left: 10),
                                child: Row(
                                  children: _getInteraction(interactions.likeList[index]),
                                ),
                              ),
                            );
                          }
                      ),
                      ListView.builder(
                          itemCount: interactions.dislikeList.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: Container(
                                height: 55,
                                padding: const EdgeInsets.only(left: 10),
                                child: Row(
                                  children: _getInteraction(interactions.dislikeList[index]),
                                ),
                              ),
                            );
                          }
                      ),
                    ],
                  )
              );
            } else {
              return const Center(
                  child: CircularProgressIndicator()
              );
            }
          }
      ),
    );
  }

  List<Widget> _getInteraction(String name) {
    final widgets = <Widget>[
      _getUserName(name),
      const Spacer(),
    ];
    if (widget.username != name) {
      widgets.add(_getAddOrRemoveButton(name));
    }
    return widgets;
  }

  Widget _getUserName(String name){
    if (widget.username != name) {
      return InkWell(
        child: Text(name),
        onTap: () => _showProfile(name),
      );
    } else {
      return Text(name);
    }
  }

  void _showProfile(String username) async {
    final token = await StorageManager.readData("token");
    final userData = await BackendAPI().getUserData(token, username);
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserInfoScreen(userData: userData))
    );
  }

  _getAddOrRemoveButton(String friend) {
    if (widget.username == friend) {
      return null;
    }
    if (widget.friendList.contains(friend)) {
      return IconButton(
          onPressed: () async {
            final token = await StorageManager.readData("token");
            final username = await StorageManager.readData("username");
            BackendAPI().removeFriend(token, username, friend)
                .whenComplete(() => setState(() {
                  friendList.remove(friend);
                })
            );
          },
          icon: const Icon(Icons.cancel)
      );
    } else {
      return IconButton(
          onPressed: () async {
            final token = await StorageManager.readData("token");
            final username = await StorageManager.readData("username");
            BackendAPI().addFriend(token, username, friend)
                .whenComplete(() => setState(() {
                  friendList.add(friend);
                })
            );
          },
          icon: const Icon(Icons.add)
      );
    }
  }

  Future<LikeDislikeList> _getInteractionLists(int contentId) async {
    final token = await StorageManager.readData("token");
    final username = await StorageManager.readData("username");
    final list = await BackendAPI().getLikeDislikeList(token, username, contentId);
    return list;
  }
}