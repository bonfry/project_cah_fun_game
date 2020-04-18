class PlayerDetails{
  int points;
  bool hasSent = false;
  List<String> whiteCardIdsOnHand;
  List<String> whiteCardIdsSelected;

  PlayerDetails({this.points = 0,}):
      whiteCardIdsOnHand = [];

  Map<String,dynamic> toMap(){
    return {
      'points' : points,
      'has_sent': hasSent,
      'white_card_hand': whiteCardIdsOnHand,
      'white_card_selected': whiteCardIdsSelected
    };
  }
}