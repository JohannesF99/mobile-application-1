import 'package:mobileapplication1/enum/Interaction.dart';

class InteractionData {
  int likes;
  int dislikes;
  late Interaction myInteraction;

  InteractionData(this.likes, this.dislikes, this.myInteraction);

  InteractionData.fromJson(Map<String, dynamic> json)
      : likes = json['likes'],
        dislikes = json['dislikes']{
    final interaction = json['userInteraction'];
    switch (interaction.toString()) {
      case 'true': myInteraction = Interaction.Like; break;
      case 'false': myInteraction = Interaction.Dislike; break;
      default: myInteraction = Interaction.None; break;
    }
  }
}