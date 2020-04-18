import 'package:projectcahfungame/session_data.dart';

import 'card.dart';
import 'enums/game_session_phase.dart';

class GameSession {
  final String id;
  Map<String, PlayerDetail> playersDetailMap;
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

  static GameSession parseMap(Map<String, dynamic> gameSession) {
    var playerDetailParsedMap = Map<String, PlayerDetail>();
    BlackCard currentBlackCard;

    (gameSession['players'] as Map<String, Object>).keys.forEach((usrName) {
      playerDetailParsedMap[usrName] =
          PlayerDetail.parseMap(gameSession['players'][usrName]);
    });

    if (gameSession['cur_black_card_id'] != null) {
      currentBlackCard = SessionData.blackCards
          .firstWhere((card) => card.id == gameSession['cur_black_card_id']);
    }

    String host = gameSession['host'];
    String blackKing = gameSession['black_king'];

    return GameSession(gameSession['id'],
        gamePhase: GameSessionPhase.values[gameSession['phase']],
        currentBlackCard: currentBlackCard,
        host: host,
        blackKing: blackKing,
        playersDetailMap: playerDetailParsedMap);
  }
}

class PlayerDetail {
  int points;
  bool hasSent;
  List<WhiteCard> whiteCardDeck;
  List<WhiteCard> whiteCardsChoose;

  PlayerDetail(
      {this.points = 0,
      this.whiteCardsChoose,
      this.whiteCardDeck,
      this.hasSent}) {
    whiteCardsChoose = whiteCardsChoose == null ? [] : whiteCardsChoose;
  }

  static PlayerDetail parseMap(Map<String, dynamic> playerDetails) {
    var whiteCardsOnHandParsed = <WhiteCard>[];
    var whiteCardSelectedParsed = <WhiteCard>[];

    var wCardsOnHand = List<String>.from(playerDetails['white_card_hand']);
    var wCardsSelected = playerDetails['white_card_selected'] != null
        ? List<String>.from(playerDetails['white_card_selected'])
        : <WhiteCard>[];

    whiteCardSelectedParsed = wCardsSelected
        .map((cId) =>
            SessionData.whiteCards.firstWhere((card) => card.id == cId))
        .toList();

    whiteCardsOnHandParsed = wCardsOnHand
        .map((cId) =>
            SessionData.whiteCards.firstWhere((card) => card.id == cId))
        .toList();

    return PlayerDetail(
        points: playerDetails['points'],
        hasSent: playerDetails['has_sent'],
        whiteCardDeck: whiteCardsOnHandParsed,
        whiteCardsChoose: whiteCardSelectedParsed);
  }
}
