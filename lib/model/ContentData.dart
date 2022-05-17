import 'package:mobileapplication1/model/InteractionData.dart';

class ContentData {
  int? contentId;
  String caption;
  InteractionData? interactionData;

  ContentData(this.contentId, this.caption)
      : interactionData = null;

  ContentData.withoutId(this.caption)
      : contentId = null,
        interactionData = null;

  ContentData.fromJson(Map<String, dynamic> json)
      : contentId = json['contentId'],
        caption = json['caption'],
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