import 'dart:convert';
import 'dart:io';

import 'package:cah_common_values/request.dart';
import 'package:cah_common_values/request_name.dart';

import '../models/game_session.dart';
import '../sever_data.dart';
import 'game_session_controller.dart';
import 'session_join_controller.dart';

/// Controller for managing requests and responding to clients
class RequestController {
  /// Parse the request and call the selected
  static void parseRequest(String requestString, WebSocket socket) {
    Map requestJsonMap = jsonDecode(requestString);
    var request = Request.fromJson(requestJsonMap, wsConnection: socket);

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
      case RequestName.RECOVER_SESSION_REQUEST:
        return SessionJoinController.recoverSession(request);
        break;
    }

    broadcastResponse(gameSessionToBroadcast);
  }

  /// Send new game session to other clients in the same session
  static void broadcastResponse(GameSession gameSessionToBroadcast) {
    for (var player in gameSessionToBroadcast.playersDetailsMap.keys) {
      try {
        // ignore: close_sinks
        var playerSocket = ServerData.userConnections[player].socket;
        var jsonEncodedResponse = jsonEncode(gameSessionToBroadcast);
        playerSocket.add(jsonEncodedResponse);
      } catch (err) {
        print('Broadcast error: $err');
      }
    }
  }
}
