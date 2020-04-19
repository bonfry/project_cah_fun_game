import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../lib_webserver/models/enums/game_session_phase.dart';
import '../lib_webserver/models/game_session.dart';

import 'bot_print_helper.dart';
import '../lib_webserver/models/request.dart';
import 'card_controllet.dart';

void main() async {
  var blackCards = CardController.loadBlackCards();
  var randomGenerator = Random();
  var jsonParser = JsonDecoder();

  print('Inserisci i bot da generare');
  var botCount = int.tryParse(stdin.readLineSync());

  print('Inserisci codice sessione');
  var sessionCode = stdin.readLineSync();

  for (var i = 0; i < botCount; i++) {
    // ignore: close_sinks
    WebSocket socket;
    var isChoosing = false;
    var username = 'player_bot_$i';
    String userToken;

    try {
      socket = await WebSocket.connect('ws://localhost:4040/ws');
    } catch (err) {
      printBotError(err.toString(), botId: i);
      return;
    }

    printBotSuccessMessage(
        'Socket connesso all\'indirizzo ws://localhost:4040/ws',
        botId: i);

    var loginRequest = Request(RequestName.SIGN_IN_REQUEST, {});

    if (sessionCode.isNotEmpty) {
      loginRequest.params['session_id'] = sessionCode;
    }

    loginRequest.params['username'] = username;

    var loginRequestParsed = loginRequest.toString();
    printBotSocketOutput(loginRequestParsed, botId: i);

    socket.add(loginRequestParsed);

    socket.listen((data) {
      printBotSocketInput(data, botId: i);
      if (data == 'disconected') {
        return;
      }

      Map<String, dynamic> json = jsonParser.convert(data);

      if (json.containsKey('user_token')) {
        userToken = json['user_token'];

        return;
      }

      var session = GameSession.parseMap(json);

      if (session.phase == GameSessionPhase.START_TURN &&
          !session.playersDetailsMap[username].hasSent &&
          !isChoosing) {
        isChoosing = true;
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

        printBotSocketOutput(request.toString(), botId: i);
        socket.add(request.toString());
        isChoosing = false;
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
            .then((value) => socket.add(request.toString()))
            .then(
                (value) => printBotSocketOutput(request.toString(), botId: i));
      }
    }, onError: (err) {
      printBotError('Errore Connessione Socket => $err', botId: i);
    });
  }
}
