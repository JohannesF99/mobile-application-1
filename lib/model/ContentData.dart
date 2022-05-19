import 'package:mobileapplication1/model/InteractionData.dart';
import 'package:mobileapplication1/model/UserData.dart';

class ContentData {
  int? contentId;
  String caption;
  DateTime created;
  UserData? userData;
  InteractionData? interactionData;

  ContentData(this.contentId, this.caption, String createdString, this.userData)
      : created = DateTime.parse(createdString),
        interactionData = null;

  ContentData.withoutId(this.caption)
      : contentId = null,
        created = DateTime.now(),
        userData = null,
        interactionData = null;

  ContentData.fromJson(Map<String, dynamic> json)
      : contentId = json['contentId'],
        caption = json['caption'],
        created = DateTime.parse(json['created'].toString()),
        userData = UserData.fromJson(json['userData']),
        interactionData = null;

  String toJson() => {
    '"contentId"': '"$contentId"',
    '"caption"': '"$caption"',
  }.toString();

  String toJsonWithoutId() => {
    '"caption"': '"$caption"'
        .trim()
        .replaceAll("\n", "\\n"),
  }.toString();
}