import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:cah_common_values/card.dart';
import 'package:cah_common_values/request.dart';
import 'package:cah_common_values/request_name.dart';
import 'package:projectcahfungame/models/game_session.dart';
import 'package:projectcahfungame/models/user.dart';
import 'package:projectcahfungame/session_data.dart';

/// Session update callback
typedef void OnGameSessionUpdate(GameSession session);

//Tmp hostname variable
const String HOSTNAME = 'docktest.westeurope.cloudapp.azure.com:5000';

/// Static class for manage the communication between client and server
class GameSessionManager {
  static bool isConnectedToServer = false;
  static GameSession currentGameSession;
  static WebSocket _socketChannel;

  static StreamController<User> _onLoginStreamController = 
  StreamController<User>.broadcast();
  static StreamController<GameSession> _onSessionUpdateStreamController =
      StreamController<GameSession>.broadcast();
  static StreamController<MessageEvent> _onSessionCloseStreamController =
      StreamController<MessageEvent>.broadcast();
  static StreamController<CloseEvent> _onConnectionCloseStreamController =
      StreamController<CloseEvent>.broadcast();
  static StreamController<Event> _onConnectionStreamController =
      StreamController<Event>.broadcast();
  static StreamController<CloseEvent> _onConnectionLostStreamController =
      StreamController<CloseEvent>.broadcast();
  static StreamController<MessageEvent> _onConnectionRecoveredStreamController =
      StreamController<MessageEvent>.broadcast();

  ///Init the WebSocket connection and set up its listeners
  static void init() {
    if (_socketChannel != null &&
        _socketChannel.readyState != WebSocket.CLOSED) {
      return;
    }

    _socketChannel = WebSocket('ws://$HOSTNAME/ws');
    _setUpSocketListener();
    _setUpSocketDisconnection();
  }

  static Stream<User> get onLogin => _onLoginStreamController.stream;

  static Stream<GameSession> get onSessionUpdate => _onSessionUpdateStreamController.stream;

  static Stream<MessageEvent> get onSessionClose => _onSessionCloseStreamController.stream;

  static Stream<Event> get onConnection => _onConnectionStreamController.stream;

  static Stream<CloseEvent> get onConnectionLost => _onConnectionLostStreamController.stream;

  static Stream<MessageEvent> get onConnectionRecoverd => _onConnectionRecoveredStreamController.stream;

  static Stream<CloseEvent> get onConnectionClose => _onConnectionCloseStreamController.stream;

  ///Sets up socket opening event listeners
  static void _setUpSocketListener() {
    _socketChannel.onOpen.listen((event) {
      isConnectedToServer = true;
      _onConnectionStreamController.add(event);
    });

    _socketChannel.onMessage.listen((messageEvent) {
      if (messageEvent.data == 'disconected') {
        return _onSessionCloseStreamController.add(messageEvent);
      } else if (messageEvent.data == 'ping') {
        User.getInstance().then((user) {
          if (user != null) {
            pingServer();
          }
        });

        return;
      }

      var socketResponse = jsonDecode(messageEvent.data);

      if (socketResponse.containsKey('user_token') &&
          socketResponse.containsKey('username')) {
        String userToken = socketResponse['user_token'];
        String userName = socketResponse['username'];
        var user = User.login(userName, userToken);
        SessionData.setUser(user);
        _onLoginStreamController.add(user);
      } else if (socketResponse.containsKey('error')) {
        throw ServerError(socketResponse['error']);
      } else {
        currentGameSession = GameSession.fromJson(socketResponse);
        _onSessionUpdateStreamController.add(currentGameSession);
      }
    });
  }

  ///Sets up socket closing event listeners
  static void _setUpSocketDisconnection() {
    _socketChannel.onClose.listen((event) async {
      _onConnectionLostStreamController.add(event);

      int trials = 0;
      WebSocket newWsConnection;

      while (trials < 5) {
        try {
          newWsConnection = await _tryToReconnect();
          break;
        } catch (e) {
          trials++;
          await Future.delayed(Duration(seconds: 30));
        }
      }

      if (newWsConnection != null) {
        _socketChannel = newWsConnection;
        _setUpSocketListener();
        _setUpSocketDisconnection();
        _onConnectionRecoveredStreamController.add(await _onConnectionStreamController.stream.last);
        recoverSession();
      }else{
        _onConnectionCloseStreamController.add(event);
      }
    });
  }

  /// Try to reconnect after WebSocket disconnection for 3 times
  static Future<WebSocket> _tryToReconnect() async {
    var _completer = Completer<WebSocket>();

    var newWebSocketConnection = WebSocket('ws://$HOSTNAME/ws');

    newWebSocketConnection.onOpen.listen((event) {
      _completer.complete(newWebSocketConnection);
    });

    newWebSocketConnection.onError.listen((event) {
      _completer.completeError(Exception("I can't connect to server"));
    });

    return _completer.future;
  }

  static StreamController<void> _disposeController = StreamController<void>();

  static Stream<void> get _onDispose => _disposeController.stream;

  static void dispose() {
    _onConnectionCloseStreamController.close();
    _onConnectionLostStreamController.close();
    _onConnectionStreamController.close();
    _onConnectionRecoveredStreamController.close();
    _onSessionUpdateStreamController.close();
    _onSessionCloseStreamController.close();
    _onLoginStreamController.close();

    _disposeController.add(null);
    _disposeController.close();
  }

  /// Sign in to server and create or join to a server
  static signIn(String username, {String gameSessionId}) {
    var params = {
      'username': username,
    };

    if (gameSessionId != null) {
      params['session_id'] = gameSessionId;
    }

    _sendMessageToServer('signIn', params);
  }

  ///Wrapper for sending messages to server
  static _sendMessageToServer(
      String requestName, Map<String, dynamic> params) async {
    var user = await SessionData.getUser();

    if (user != null) {
      params['user_token'] = user.token;
    }

    var request = Request(requestName, params);
    var serializedRequest = jsonEncode(request);

    _socketChannel.send(serializedRequest);
  }

  /// When user is a black king send a black card compiled which has been
  /// chosen from him
  static chooseBlackCard(String playerWinner) {
    _sendMessageToServer(RequestName.SELECT_BLACK_CARD_REQUEST,
        {'player_turn_winner': playerWinner});
  }

  /// Players in send theirs white card choice which will'be used to compile
  /// current black card
  static void chooseWhiteCards(List<WhiteCard> cards) {
    _sendMessageToServer(RequestName.SEND_WHITE_CARDS_REQUEST,
        {'white_card_indexes': cards.map((c) => c.id).toList()});
  }

  ///Send init game signal
  static void initGame() {
    _sendMessageToServer(RequestName.INIT_GAME_REQUEST, {});
  }

  /// Send end game signal
  static void finishGame() {
    _sendMessageToServer(RequestName.FINISH_GAME_REQUEST, {});
  }

  /// Kick player fom session
  static removePlayer(String username) {
    _sendMessageToServer(
        RequestName.REMOVE_PLAYER_REQUEST, {'username': username});
  }

  /// Log out user from session
  static void logoutFromGame() {
    SessionData.getUser().then((user) => removePlayer(user.username));
  }

  /// Try to recover current session after disconnection
  static void recoverSession() {
    if (currentGameSession != null) {
      _sendMessageToServer(RequestName.RECOVER_SESSION_REQUEST, {});
    }
  }

  ///Ping the server for maintaining the web socket connection
  static void pingServer() {
    _socketChannel.send('pong');
  }

  static Future addBot(String sessionToken, int botQuantity) async {
    return HttpRequest.request('http://$HOSTNAME/bot/create-bot',
        method: 'POST',
        sendData: jsonEncode(
            {'session_token': sessionToken, 'quantity': botQuantity}));
  }
}

/// Exception use for prompt exceptions from server
class ServerError extends Error {
  String message;
  ServerError(this.message);

  @override
  String toString() {
    return 'Error from ws server: $message';
  }
}
