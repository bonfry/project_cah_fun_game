import 'dart:convert';
import 'dart:io';

import '../models/game_session.dart';
import '../models/request.dart';
import '../sever_data.dart';
import 'game_session_controller.dart';
import 'session_join_controller.dart';

class RequestController {
  static void parseRequest(String requestString, WebSocket socket) {
    Map<String, dynamic> requestJsonMap = JsonDecoder().convert(requestString);
    var request = Request.parseJson(requestJsonMap, socket: socket);

    GameSession gameSessionToBroadcast;

    switch (request.requestName) {
      case RequestName.SIGN_IN_REQUEST:
        gameSessionToBroadcast = SessionJoinController.signIn(request);
        break;
      case RequestName.INIT_GAME_REQUEST:
        gameSessionToBroadcast = GameSessionController.initGame(request);
        break;
      case RequestName.SEND_WHITE_CARDS_REQUEST:
        gameSessionToBroadcast = GameSessionController.sendWhiteCards(request);
        break;
      case RequestName.SELECT_BLACK_CARD_REQUEST:
        gameSessionToBroadcast = GameSessionController.selectBlackCard(request);
        break;
      case RequestName.FINISH_GAME_REQUEST:
        gameSessionToBroadcast = GameSessionController.finishGame(request);
        break;
      case RequestName.REMOVE_PLAYER_REQUEST:
        gameSessionToBroadcast = GameSessionController.removeUser(request);
        break;
    }

    broadcastResponse(gameSessionToBroadcast);
  }

  static void broadcastResponse(GameSession gameSessionToBroadcast) {
    var jsonEncoder = JsonEncoder();

    for (var player in gameSessionToBroadcast.playersDetailsMap.keys) {
      try {
        // ignore: close_sinks
        var playerSocket = ServerData.userConnections[player].socket;
        var jsonEncodedResponse =
            jsonEncoder.convert(gameSessionToBroadcast.toMap());
        playerSocket.add(jsonEncodedResponse);
      } catch (err) {
        print('Errore in broadcast: $err');
      }
    }
  }
}
