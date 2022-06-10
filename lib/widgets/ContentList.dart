import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mobileapplication1/model/ContentData.dart';
import 'package:mobileapplication1/screen/InteractionScreen.dart';

import '../api/BackendAPI.dart';
import '../enum/Interaction.dart';
import '../utils/StoreManager.dart';

class ContentList extends StatefulWidget{
  const ContentList({
    Key? key, 
    required this.content,
    this.showEditingOptions = false
  }) : super(key: key);

  final List<ContentData> content;
  final bool showEditingOptions;
  
  @override
  State<StatefulWidget> createState() => _ContentList();
}

class _ContentList extends State<ContentList> {

  late List<ContentData> contentList;

  @override
  void initState() {
    contentList = widget.content;
    contentList.sort((a, b){
      if (a.created.isBefore(b.created)) {
        return 1;
      }
      return -1;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(0),
      shrinkWrap: true,
      itemCount: contentList.length,
      itemBuilder: (context, index) {
        return LimitedBox(
          maxHeight: 200,
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    padding: const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            contentList[index].userData!.username,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          style: TextButton.styleFrom(
                            fixedSize: const Size.fromHeight(10),
                            padding: const EdgeInsets.all(0)
                          ),
                        ),
                        const Spacer(),
                        Text(
                            _getPostTime(contentList[index].created)
                        )
                      ],
                    ),
                  ),
                const Divider(),
                Container(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Text(
                      contentList[index].caption,
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 5,
                    ),
                  ),
                const Spacer(),
                Row(
                  children: _getFooter(index),
                ),
              ],
            )
          ),
        );
      },
    );
  }

  Color _getColor(Interaction my, Interaction interaction) {
    if (interaction == my){
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
  
  List<Widget> _getFooter(int index){
    final _changeController = TextEditingController();
    var footer = [
      IconButton(
        onPressed: () async {
          final token = await StorageManager.readData("token");
          final username = await StorageManager.readData("username");
          final contentId = contentList[index].contentId!;
          if (contentList[index].interactionData!.myInteraction == Interaction.Dislike || contentList[index].interactionData!.myInteraction == Interaction.None) {
            final result = await BackendAPI().likeContent(token, username, contentId);
            if (result && contentList[index].interactionData!.myInteraction == Interaction.Dislike) {
              contentList[index].interactionData!.likes++;
              contentList[index].interactionData!.dislikes--;
              contentList[index].interactionData!.myInteraction = Interaction.Like;
            } else if (result && contentList[index].interactionData!.myInteraction == Interaction.None) {
              contentList[index].interactionData!.likes++;
              contentList[index].interactionData!.myInteraction = Interaction.Like;
            }
          } else {
            final result = await BackendAPI().removeInteraction(token, username, contentId);
            if (result && contentList[index].interactionData!.myInteraction == Interaction.Dislike) {
              contentList[index].interactionData!.dislikes--;
              contentList[index].interactionData!.myInteraction = Interaction.None;
            } else if (result && contentList[index].interactionData!.myInteraction == Interaction.Like) {
              contentList[index].interactionData!.likes--;
              contentList[index].interactionData!.myInteraction = Interaction.None;
            }
          }
          setState(() {});
        },
        icon: const Icon(Icons.keyboard_arrow_up),
        color: _getColor(contentList[index].interactionData!.myInteraction, Interaction.Like),
      ),
      SizedBox(
        width: MediaQuery.of(context).size.width/10,
        child: TextButton(
          child: Text("${contentList[index].interactionData!.likes - contentList[index].interactionData!.dislikes}"),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InteractionScreen(contentId: contentList[index].contentId!),)
            );
          },
        ),
      ),
      IconButton(
        onPressed: () async {
          final token = await StorageManager.readData("token");
          final username = await StorageManager.readData("username");
          final contentId = contentList[index].contentId!;
          if (contentList[index].interactionData!.myInteraction == Interaction.Like || contentList[index].interactionData!.myInteraction == Interaction.None) {
            final result = await BackendAPI().dislikeContent(token, username, contentId);
            if (result && contentList[index].interactionData!.myInteraction == Interaction.Like) {
              contentList[index].interactionData!.likes--;
              contentList[index].interactionData!.dislikes++;
              contentList[index].interactionData!.myInteraction = Interaction.Dislike;
            } else if (result && contentList[index].interactionData!.myInteraction == Interaction.None) {
              contentList[index].interactionData!.dislikes++;
              contentList[index].interactionData!.myInteraction = Interaction.Dislike;
            }
          } else {
            final result = await BackendAPI().removeInteraction(token, username, contentId);
            if (result && contentList[index].interactionData!.myInteraction == Interaction.Dislike) {
              contentList[index].interactionData!.dislikes--;
              contentList[index].interactionData!.myInteraction = Interaction.None;
            } else if (result && contentList[index].interactionData!.myInteraction == Interaction.Like) {
              contentList[index].interactionData!.likes--;
              contentList[index].interactionData!.myInteraction = Interaction.None;
            }
          }
          setState(() {});
        },
        icon: const Icon(Icons.keyboard_arrow_down),
        color: _getColor(contentList[index].interactionData!.myInteraction, Interaction.Dislike),
      ),
    ];
    if(widget.showEditingOptions) {
      footer.addAll([
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            _changeController.text = contentList[index].caption;
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
                          BackendAPI().changeContent(token, username, contentList[index].contentId!, _changeController.text)
                              .then((success) {
                            if(success) contentList[index].caption = _changeController.text;
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
              final contentId = contentList[index].contentId!;
              final result = await BackendAPI().deleteUserContent(token, username, contentId);
              if (result) {
                setState(() {
                  contentList.removeAt(index);
                });
              }
            },
            icon: const Icon(Icons.delete_sweep_outlined)
        ),
      ]);
    }
    return footer;
  }
  
}