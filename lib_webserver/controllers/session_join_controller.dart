import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../models/enums/game_session_phase.dart';
import '../models/game_session.dart';
import '../models/request.dart';
import '../models/user.dart';
import '../sever_data.dart';
import 'card_controllet.dart';

//Class used for session access
class SessionJoinController {
  // Sign in the session
  static GameSession signIn(Request request) {
    var sessionId = request.params['session_id'];
    var username = request.params['username'];

    if (ServerData.userConnections.keys.contains(username)) {
      throw Exception('username already insert');
    }

    var userId = Uuid().v5(Uuid.NAMESPACE_NIL, username);
    var userDetails =
        UserConnectionDetails(token: userId, socket: request.wsConnection);

    ServerData.userConnections[username] = userDetails;

    request.wsConnection.add(
        JsonEncoder().convert({'user_token': userId, 'username': username}));

    GameSession session;

    if (sessionId != null) {
      session = _joinToSession(sessionId, username);
    } else {
      session = _createSession(username);
    }

    return session;
  }

  // Create a session and add user to playersMap
  static GameSession _createSession(String username) {
    var sessionId = Uuid().v1();
    var session = GameSession(sessionId, host: username);

    session.phase = GameSessionPhase.LOBBY;
    session.addPlayer(username);

    ServerData.gameSessions.add(session);

    return session;
  }

  // Find session and add user to player map
  static GameSession _joinToSession(String sessionId, String username) {
    var sessionFound =
        ServerData.gameSessions.firstWhere((s) => s.id == sessionId);

    if (sessionFound == null) {
      throw Exception('Session not found');
    }

    sessionFound.addPlayer(username);

    if (sessionFound.phase == GameSessionPhase.START_TURN) {
      CardController.giveCardsToPlayer(sessionFound);
    }

    return sessionFound;
  }
}
