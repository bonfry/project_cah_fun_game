import 'package:cah_common_values/request.dart';
import 'package:cah_common_values/enums/game_session_phase.dart';

import '../models/game_session.dart';
import '../sever_data.dart';
import 'card_controller.dart';
import 'user_controller.dart';


///Controller for serving requests abaut the game
class GameSessionController {

  ///Checks players who have sent white cards
  static GameSession sendWhiteCards(Request request) {
    var userToken = request.params['user_token'];
    var whiteCardsIds = List<String>.from(request.params['white_card_indexes']);
    var username = UserController.getUsernameByToken(userToken);
    var gameSession = getSessionByUsername(username);

    gameSession.playersDetailsMap[username]
      ..whiteCardIdsSelected = whiteCardsIds
      ..hasSent = true;

    if (_checkIfAllPlayersHaveSent(gameSession)) {
      gameSession.phase = GameSessionPhase.CHOICE_BLACK;
    }

    return gameSession;
  }

  ///Controls if all human players have sent white cards
  static bool checkIfAllRealPlayersSentWhiteCards(GameSession gameSession) {
    var realPlayers = gameSession.playersDetailsMap.entries
        .where((playerEntry) =>
            !RegExp(r"bot_.*").hasMatch(playerEntry.key) &&
            playerEntry.value.online)
        .toList();

    var realPlayersWhoSentWhiteCardsCount = realPlayers.where((playerEntry) {
      var hasSent = playerEntry.value.hasSent;
      var isBlackKing = gameSession.blackKing == playerEntry.key;

      return hasSent || isBlackKing;
    }).toList().length;

    return realPlayersWhoSentWhiteCardsCount == realPlayers.length;
  }

  /// Controls if all players have sent white cards
  static bool _checkIfAllPlayersHaveSent(GameSession gameSession) {
    var onlinePlayersUsername = gameSession.playersDetailsMap.entries
        .where((playerEntry) => playerEntry.value.online);

    var playersWhoSentWhiteCardCount = onlinePlayersUsername.where((playerEntry) {
      var hasSent = playerEntry.value.hasSent;
      var isBlackKing = gameSession.blackKing == playerEntry.key;

      return hasSent || isBlackKing;
    }).length;

    return playersWhoSentWhiteCardCount == onlinePlayersUsername.length;
  }



  static void allowNextBotToSendWhiteCards(GameSession gameSession) {
    var nextBotUsername = gameSession.playersDetailsMap.entries
        .where((playerEntry) =>
            RegExp(r"bot_.*").hasMatch(playerEntry.key) &&
            playerEntry.value.online &&
            !playerEntry.value.hasSent &&
            gameSession.blackKing != playerEntry.key)
        .first
        ?.key;
    if (ServerData.userConnections.containsKey(nextBotUsername)) {
      ServerData.userConnections[nextBotUsername].socket.add('send_data');
    }
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
