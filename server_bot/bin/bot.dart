import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cah_common_values/enums/game_session_phase.dart';
import 'package:cah_common_values/request.dart';
import 'package:cah_common_values/request_name.dart';

import '../../server_web/bin/models/game_session.dart';
import 'main.dart';

Random randomGenerator = Random();

class Bot {
  final String username;
  final WebSocket socket;
  String userToken;
  GameSession gameSession;

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
    } else if (data == 'ping') {
      socket.add('pong');
      return;
    }else if (data == 'send_data' && gameSession.phase == GameSessionPhase.START_TURN){
      return chooseAndSendWhiteCards();
    }

    Map<String, dynamic> json = jsonDecode(data);

    if (json.containsKey('user_token')) {
      userToken = json['user_token'];

      return;
    }

    if (json.containsKey('error')) {
      logout();
    }

    gameSession = GameSession.parseMap(json);

    if (gameSession.phase == GameSessionPhase.CHOICE_BLACK &&
        gameSession.blackKing == username) {
      var usersToChoice = gameSession.playersDetailsMap.keys
          .where((_username) => _username != gameSession.blackKing);

      var randomUserIndex = usersToChoice.length == 1
          ? 0
          : randomGenerator.nextInt(usersToChoice.length - 1);

      var request = Request(RequestName.SELECT_BLACK_CARD_REQUEST, {
        'player_turn_winner': usersToChoice.elementAt(randomUserIndex),
        'user_token': userToken
      });

      Future.delayed(Duration(seconds: 50))
          .then((value) => socket.add(request.toString()));
    }
  }

  void logout() async {
    socket.close();
  }

  void chooseAndSendWhiteCards(){
    int whiteCardCount =
          gameSession.playersDetailsMap[username].whiteCardIdsOnHand.length;
      var blackCard =
          blackCards.firstWhere((c) => c.id == gameSession.currentBlackCardId);
      var whiteCardsNeeded = '<*>'.allMatches(blackCard.text).length;
      var outputWhiteCards = <String>[];

      while (outputWhiteCards.length < whiteCardsNeeded) {
        var randomCardIndex = randomGenerator.nextInt(whiteCardCount - 1);
        var whiteRandomCard = gameSession
            .playersDetailsMap[username].whiteCardIdsOnHand
            .removeAt(randomCardIndex);

        outputWhiteCards.add(whiteRandomCard);
      }

      var request = Request(RequestName.SEND_WHITE_CARDS_REQUEST,
          {'white_card_indexes': outputWhiteCards, 'user_token': userToken});

      socket.add(request.toString());
  }
}
