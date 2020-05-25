import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cah_common_values/enums/game_session_phase.dart';
import 'package:cah_common_values/request.dart';
import 'package:cah_common_values/request_name.dart';

import '../../lib_webserver/bin/models/game_session.dart';
import 'main.dart';

Random randomGenerator = Random();

class Bot {
  final String username;
  final WebSocket socket;
  String userToken;

  bool _isChoosing = false;

  Bot(this.username, this.socket, {this.userToken});

  void init(String sessionCode) {
    var loginRequest = Request(RequestName.SIGN_IN_REQUEST, {});

    if (sessionCode.isNotEmpty) {
      loginRequest.params['session_id'] = sessionCode;
    }

    loginRequest.params['username'] = username;

    var loginRequestParsed = loginRequest.toString();
    socket.add(loginRequestParsed);

    socket.listen(_manageMessage);
  }

  void _manageMessage(data) {
    if (data == 'disconected') {
      return;
    }

    Map<String, dynamic> json = jsonDecode(data);

    if (json.containsKey('user_token')) {
      userToken = json['user_token'];

      return;
    }

    var session = GameSession.parseMap(json);

    if (session.phase == GameSessionPhase.START_TURN &&
        !session.playersDetailsMap[username].hasSent &&
        !_isChoosing) {
      _isChoosing = true;
      int whiteCardCount =
          session.playersDetailsMap[username].whiteCardIdsOnHand.length;
      var blackCard =
          blackCards.firstWhere((c) => c.id == session.currentBlackCardId);
      var whiteCardsNeeded = '<*>'.allMatches(blackCard.text).length;
      var outputWhiteCards = <String>[];

      while (outputWhiteCards.length < whiteCardsNeeded) {
        var randomCardIndex = randomGenerator.nextInt(whiteCardCount - 1);
        var whiteRandomCard = session
            .playersDetailsMap[username].whiteCardIdsOnHand
            .removeAt(randomCardIndex);

        outputWhiteCards.add(whiteRandomCard);
      }

      var request = Request(RequestName.SEND_WHITE_CARDS_REQUEST,
          {'white_card_indexes': outputWhiteCards, 'user_token': userToken});

      socket.add(request.toString());
      _isChoosing = false;
    } else if (session.phase == GameSessionPhase.CHOICE_BLACK &&
        session.blackKing == username) {
      var usersToChoice = session.playersDetailsMap.keys
          .where((_username) => _username != session.blackKing);

      var randomUserIndex = usersToChoice.length == 1
          ? 0
          : randomGenerator.nextInt(usersToChoice.length - 1);

      var request = Request(RequestName.SELECT_BLACK_CARD_REQUEST, {
        'player_turn_winner': usersToChoice.elementAt(randomUserIndex),
        'user_token': userToken
      });

      Future.delayed(Duration(minutes: 1))
          .then((value) => socket.add(request.toString()));
    }
  }

  void logout() async {
    socket.close();
  }
}
