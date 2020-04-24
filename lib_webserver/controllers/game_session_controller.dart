import '../models/enums/game_session_phase.dart';
import '../models/game_session.dart';
import '../models/request.dart';
import '../sever_data.dart';
import 'card_controller.dart';
import 'user_controller.dart';

class GameSessionController {
  //Method for serving requests

  static GameSession sendWhiteCards(Request request) {
    var userToken = request.params['user_token'];
    var whiteCardsIds = List<String>.from(request.params['white_card_indexes']);
    var username = UserController.getUsernameByToken(userToken);
    var gameSession = getSessionByUsername(username);

    gameSession.playersDetailsMap[username]
      ..whiteCardIdsSelected = whiteCardsIds
      ..hasSent = true;

    var playersWhoSentWhiteCards =
        gameSession.playersDetailsMap.keys.where((_username) {
      var hasSent = gameSession.playersDetailsMap[_username].hasSent;
      var isBlackKing = gameSession.blackKing == _username;

      return hasSent || isBlackKing;
    }).length;

    if (playersWhoSentWhiteCards ==
        gameSession.playersDetailsMap.values.length) {
      gameSession.phase = GameSessionPhase.CHOICE_BLACK;
    }

    return gameSession;
  }

  static GameSession initGame(Request request) {
    var userToken = request.params['user_token'];

    var session = getSessionByPlayerToken(userToken);
    session.phase = GameSessionPhase.START_GAME;

    var blackCardIdsMixed = CardController.mixCards(ServerData.blackCards)
        .map((card) => card.id)
        .toList();

    var whiteCardIdsMixed = CardController.mixCards(ServerData.whiteCards)
        .map((card) => card.id)
        .toList();

    session.whiteCardIds = whiteCardIdsMixed;
    session.blackCardIdIterator = blackCardIdsMixed.iterator;

    _prepareForNextMatch(session, randomKing: true);

    return session;
  }

  static GameSession selectBlackCard(Request request) {
    var playerTurnWinner = request.params['player_turn_winner'];
    var userToken = request.params['user_token'];
    var session = getSessionByPlayerToken(userToken);

    _addPoint(session, playerTurnWinner);
    _prepareForNextMatch(session);

    return session;
  }

  static GameSession finishGame(Request request) {
    var userToken = request.params['user_token'];

    var session = getSessionByPlayerToken(userToken);
    session.phase = GameSessionPhase.FINISH_GAME;

    return session;
  }

  static GameSession removeUser(Request request) {
    var userToken = request.params['user_token'];
    var session = getSessionByPlayerToken(userToken);
    var playerUsernameToRemove = request.params['username'];

    if (session.playersDetailsMap.keys.contains(playerUsernameToRemove)) {
      UserController.removePlayer(playerUsernameToRemove);
    }

    session = getSessionByPlayerToken(userToken);
    return session;
  }
  // General purpose methods

  static void _addPoint(GameSession session, String username) {
    session.playersDetailsMap[username].points++;
  }

  static void _prepareForNextMatch(GameSession session,
      {bool randomKing = false}) {
    session.nextBlackKing(random: randomKing);

    session.playersDetailsMap.values.forEach((player) {
      if (player.whiteCardIdsSelected != null) {
        player.whiteCardIdsSelected.forEach((whiteCard) {
          player.whiteCardIdsOnHand.remove(whiteCard);
        });
        player.hasSent = false;
        player.whiteCardIdsSelected = [];
      }
    });

    CardController.giveCardsToPlayer(session);

    if (session.blackCardIdIterator.moveNext()) {
      session.currentBlackCardId = session.blackCardIdIterator.current;
      session.phase = GameSessionPhase.START_TURN;
    } else {
      session.phase = GameSessionPhase.FINISH_GAME;
    }
  }

  static GameSession getSessionByPlayerToken(String token) {
    var username = UserController.getUsernameByToken(token);
    return getSessionByUsername(username);
  }

  static GameSession getSessionByUsername(String username) {
    return ServerData.gameSessions.firstWhere(
        (session) => session.playersDetailsMap.keys.contains(username));
  }
}
