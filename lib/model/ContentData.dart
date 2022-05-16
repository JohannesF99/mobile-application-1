class ContentData {
  int? contentId;
  String caption;

  ContentData(this.contentId, this.caption);

  ContentData.withoutId(this.caption): contentId = null;

  ContentData.fromJson(Map<String, dynamic> json)
      : contentId = json['contentId'],
        caption = json['caption'];

  String toJson() => {
    '"contentId"': '"$contentId"',
    '"caption"': '"$caption"',
  }.toString();

  String toJsonWithoutId() => {
    '"caption"': '"$caption"',
  }.toString();
}