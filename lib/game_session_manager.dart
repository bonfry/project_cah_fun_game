import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:projectcahfungame/models/game_session.dart';
import 'package:projectcahfungame/models/user.dart';
import 'package:projectcahfungame/session_data.dart';

import 'models/card.dart';

typedef void OnGameSessionUpdate(GameSession session);

class GameSessionManager {
  static bool isConnectedToServer = false;
  static GameSession currentGameSession;
  static WebSocket _socketChannel;
  static OnGameSessionUpdate _onSessionUpdate;
  static Function _onSocketDisconnection;
  static Function _onSocketConnection = () {};
  static Function _onSocketReconnection = () {};

  static void init() {
    _socketChannel = WebSocket('ws://bonfrycah.ddns.net:4040/ws');
    _setUpSocketListener();
    _setUpSocketDisconnection();
  }

  static void _setUpSocketListener() {
    _socketChannel.onOpen.listen((event) {
      isConnectedToServer = true;
      _onSocketConnection();
    });

    _socketChannel.onMessage.listen((messageEvent) {
      if (messageEvent.data == 'disconected') {
        _onSocketDisconnection();
      }
      var socketResponse = json.decode(messageEvent.data);

      if (socketResponse.containsKey('user_token') &&
          socketResponse.containsKey('username')) {
        String userToken = socketResponse['user_token'];
        String userName = socketResponse['username'];

        SessionData.setUser(User.login(userName, userToken));
      } else if (socketResponse.containsKey('error')) {
        throw ServerException(socketResponse['error']);
      } else {
        currentGameSession = GameSession.parseMap(socketResponse);
        _onSessionUpdate(currentGameSession);
      }
    });
  }

  static void _setUpSocketDisconnection() {
    _socketChannel.onClose.listen((event) {
      //TODO: Gestire riconnessione al server
      _tryToReconnect().then((ws) {
        _socketChannel = ws;
        _setUpSocketListener();
        _setUpSocketDisconnection();
        _onSocketReconnection();
      });
    });
  }

  static Future<WebSocket> _tryToReconnect({int times = 0}) async {
    var _completer = Completer<WebSocket>();

    print('Tentativo n° $times');

    var newWebSocketConnection = WebSocket('ws://bonfrycah.ddns.net:4040/ws');

    newWebSocketConnection.onOpen.listen((event) {
      print(' LA MADONNA SI E\' CONNESSA');
      _completer.complete(newWebSocketConnection);
    });
    newWebSocketConnection.onError.listen((event) {
      print('PORCO DIO BONO');
      if (times == 3) {
        throw new Exception('No connection');
      } else {
        return _tryToReconnect(times: times + 1);
      }
    });

    return _completer.future;
  }

  static void onUpdate(OnGameSessionUpdate callback) {
    _onSessionUpdate = callback;
  }

  static void onDisconnect(Function onDisconnect) {
    _onSocketDisconnection = onDisconnect;
  }

  static void onConnection(Function onConnect) {
    _onSocketConnection = onConnect;
  }

  static signIn(String username, {String gameSessionId}) {
    var params = {
      'username': username,
    };

    if (gameSessionId != null) {
      params['session_id'] = gameSessionId;
    }

    _sendMessageToServer('signIn', params);
  }

  static _sendMessageToServer(
      String requestName, Map<String, dynamic> params) async {
    var user = await SessionData.getUser();

    if (user != null) {
      params['user_token'] = user.token;
    }

    var request = {'request_name': requestName, 'params': params};
    var serializedRequest = JsonEncoder().convert(request);
    _socketChannel.send(serializedRequest);
  }

  static chooseBlackCard(String playerWinner) {
    _sendMessageToServer(
        'selectBlackCard', {'player_turn_winner': playerWinner});
  }

  static void chooseWhiteCards(List<WhiteCard> cards) {
    _sendMessageToServer('sendWhiteCards',
        {'white_card_indexes': cards.map((c) => c.id).toList()});
  }

  static void initGame() {
    _sendMessageToServer('initGame', {});
  }

  static void finishGame() {
    _sendMessageToServer('finishGame', {});
  }

  static removePlayer(String username) {
    _sendMessageToServer('removePlayer', {'username': username});
  }

  static void logoutFromGame() {
    SessionData.getUser().then((user) => removePlayer(user.username));
  }

  static void recoverSession() {
    _sendMessageToServer('recoverSession', {});
  }
}

class ServerException implements Exception {
  String message;
  ServerException(this.message);
}
