import 'package:flutter/material.dart';
import 'package:mobileapplication1/api/BackendAPI.dart';
import 'package:mobileapplication1/utils/StoreManager.dart';

import '../model/LikeDislikeList.dart';

class InteractionScreen extends StatefulWidget {
  const InteractionScreen({Key? key, required this.contentId}) : super(key: key);

  final int contentId;

  @override
  State<StatefulWidget> createState() => _InteractionScreen();
}

class _InteractionScreen extends State<InteractionScreen> {

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
                              child: Text(interactions.likeList[index]),
                            );
                          }
                      ),
                      ListView.builder(
                          itemCount: interactions.dislikeList.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: Text(interactions.dislikeList[index]),
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

  Future<LikeDislikeList> _getInteractionLists(int contentId) async {
    final token = await StorageManager.readData("token");
    final username = await StorageManager.readData("username");
    final list = await BackendAPI().getLikeDislikeList(token, username, contentId);
    return list;
  }
}