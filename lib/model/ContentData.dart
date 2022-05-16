class ContentData {
  String caption;

  ContentData(this.caption);

  ContentData.fromJson(Map<String, dynamic> json)
      : caption = json['caption'];

  String toJson() => {
    '"caption"': '"$caption"',
  }.toString();
}