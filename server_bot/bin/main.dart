import 'dart:convert';
import 'dart:io';

import 'package:cah_common_values/card.dart';

import 'bot.dart';
import 'card_controller.dart';

const String HOSTNAME = 'web-server:4040';

List<BlackCard> blackCards;
Map<String, List<Bot>> botGroupedBySessionCode = {};

void main() async {
  blackCards = CardController.loadBlackCards();
  var httpServer = await HttpServer.bind(
      '0.0.0.0', //'0.0.0.0',
      4041);

  httpServer.listen((HttpRequest req) {
    var endpointPath = req.uri.path;
    
    if (RegExp(r'^\/api.*').hasMatch(endpointPath)) {
      req.listen((data) {
        
        req.response.headers.add('Access-Control-Allow-Origin', '*');

        Map<String, dynamic> jsonData;
        try {
          jsonData = jsonDecode(String.fromCharCodes(data));

          if (RegExp(r'^\/api/create-bot').hasMatch(endpointPath)) {
            createBot(jsonData);
            req.response
              ..statusCode = 200
              ..write('{"success": true}')
              ..close();
          } else if (RegExp(r'^\/api/remove-bot').hasMatch(endpointPath)) {
            removeBot(jsonData);
            req.response
              ..statusCode = 200
              ..write('{"success": true}')
              ..close();
          } else {
            req.response
              ..statusCode = 404
              ..write('{"error":"endpoint not found"}')
              ..close();
          }
        } catch (err) {
          req.response
            ..statusCode = 500
            ..write('{"error":"$err"}')
            ..close();
        }
      });
    } else {
      req.response
        ..statusCode = 500
        ..write('{"error":"endpoint must start with /api "}')
        ..close();
    }
  });
}

/**
 * Controller which creates bot.
 *
 *  Required params:
 *
 ** [String] session_token
 ** [int] quantity
 */
void createBot(Map<String, dynamic> data) async {
  var sessionToken = data['session_token'] as String;
  var botQuantity = data['quantity'];

  for (int i = 0; i < botQuantity; i++) {
    int botId = botGroupedBySessionCode.containsKey(sessionToken)
        ? botGroupedBySessionCode[sessionToken].length + 1
        : 1;

    var botHash = '${sessionToken}_${botId}_${DateTime.now()}'.hashCode;
    var username = 'bot_$botHash';

    try {
      WebSocket socket = await WebSocket.connect('ws://$HOSTNAME/ws');
      var bot = Bot(username, socket);

      bot.init(sessionToken);

      if (botGroupedBySessionCode.containsKey(sessionToken)) {
        botGroupedBySessionCode[sessionToken].add(bot);
      } else {
        botGroupedBySessionCode[sessionToken] = [bot];
      }
    } catch (err) {
      print(err);
    }
  }
}

/**
 * Controller which creates bot.
 *
 *  Required params:
 *
 ** [String] session_token
 ** [List<String>] bot_usernames
 */
void removeBot(Map<String, dynamic> data) {
  var sessionToken = data['session_token'] as String;
  var botUsernames = data['bot_usernames'] as List;

  botGroupedBySessionCode[sessionToken]
      .where((bot) => botUsernames.contains(bot.username))
      .forEach((bot) {
    bot.logout();
    botGroupedBySessionCode[sessionToken].remove(bot);
  });
}
