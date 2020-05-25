import 'package:cah_common_values/card.dart';
import 'package:cah_common_values/enums/game_session_phase.dart';
import 'package:projectcahfungame/session_data.dart';

/// For managing the session in the client
class GameSession {
  final String id;
  Map<String, PlayerDetails> playersDetailMap;
  BlackCard currentBlackCard;
  GameSessionPhase gamePhase;
  String blackKing;
  String host;

  GameSession(this.id,
      {this.gamePhase,
      this.playersDetailMap,
      this.currentBlackCard,
      this.host,
      this.blackKing});

  //Create GameSession from JSON Map
  factory GameSession.fromJson(Map<String, dynamic> json) {
    Map playersUnparsed = json['players'];
    BlackCard currentBlackCard;

    Map<String, PlayerDetails> playersDetailsParsed = playersUnparsed
        .map((key, pdJson) => MapEntry(key, PlayerDetails.fromJson(pdJson)));

    if (json['cur_black_card_id'] != null) {
      currentBlackCard = SessionData.blackCards
          .firstWhere((card) => card.id == json['cur_black_card_id']);
    }

    String host = json['host'];
    String blackKing = json['black_king'];

    return GameSession(json['id'],
        gamePhase: GameSessionPhase.values[json['phase']],
        currentBlackCard: currentBlackCard,
        host: host,
        blackKing: blackKing,
        playersDetailMap: playersDetailsParsed);
  }
}

///Player information about own game session
class PlayerDetails {
  int points;
  bool hasSent;
  List<WhiteCard> whiteCardDeck;
  List<WhiteCard> whiteCardsChoose;

  PlayerDetails(
      {this.points = 0,
      this.whiteCardsChoose,
      this.whiteCardDeck,
      this.hasSent = false}) {
    whiteCardsChoose = whiteCardsChoose == null ? [] : whiteCardsChoose;
  }

  /// Create [PlayerDetails] from JSON
  factory PlayerDetails.fromJson(Map<String, dynamic> json) {
    var whiteCardsOnHandParsed = <WhiteCard>[];
    var whiteCardSelectedParsed = <WhiteCard>[];

    var wCardsOnHand = List<String>.from(json['white_card_hand']);
    var wCardsSelected = json['white_card_selected'] != null
        ? List<String>.from(json['white_card_selected'])
        : [];

    whiteCardSelectedParsed = wCardsSelected
        .map((cId) =>
            SessionData.whiteCards.firstWhere((card) => card.id == cId))
        .toList();

    whiteCardsOnHandParsed = wCardsOnHand
        .map((cId) =>
            SessionData.whiteCards.firstWhere((card) => card.id == cId))
        .toList();

    return PlayerDetails(
        points: json['points'] as int,
        hasSent: json['has_sent'] as bool,
        whiteCardDeck: whiteCardsOnHandParsed,
        whiteCardsChoose: whiteCardSelectedParsed);
  }
}
