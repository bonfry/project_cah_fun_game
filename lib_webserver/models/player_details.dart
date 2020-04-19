class PlayerDetails {
  int points;
  bool hasSent = false;
  List<String> whiteCardIdsOnHand;
  List<String> whiteCardIdsSelected;

  PlayerDetails(
      {this.points = 0,
      this.whiteCardIdsOnHand,
      this.whiteCardIdsSelected,
      this.hasSent = false}) {
    whiteCardIdsOnHand ??= [];
  }

  static PlayerDetails parseMap(Map<String, dynamic> playerDetails) {
    var wCardsOnHand = List<String>.from(playerDetails['white_card_hand']);
    var wCardsSelected = playerDetails['white_card_selected'] != null
        ? List<String>.from(playerDetails['white_card_selected'])
        : <String>[];

    return PlayerDetails(
        points: playerDetails['points'],
        hasSent: playerDetails['has_sent'],
        whiteCardIdsOnHand: wCardsOnHand,
        whiteCardIdsSelected: wCardsSelected);
  }

  Map<String, dynamic> toMap() {
    return {
      'points': points,
      'has_sent': hasSent,
      'white_card_hand': whiteCardIdsOnHand,
      'white_card_selected': whiteCardIdsSelected
    };
  }
}
