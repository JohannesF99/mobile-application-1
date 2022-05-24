class LikeDislikeList {
  List<String> likeList;
  List<String> dislikeList;

  LikeDislikeList(this.likeList, this.dislikeList);

  LikeDislikeList.fromJson(Map<String, dynamic> json)
      : likeList = List<String>.from(json['likeList']),
        dislikeList = List<String>.from(json['dislikeList']);
}