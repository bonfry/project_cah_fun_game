import 'dart:convert';
import 'dart:io';

import 'package:cah_common_values/card.dart';

import 'bot.dart';
import 'bot_print_helper.dart';
import 'card_controller.dart';

const String HOSTNAME = 'cahbackend:4040';
List<BlackCard> blackCards;
Map<String, List<Bot>> botGroupedBySessionCode;

void main() async {
  blackCards = CardController.loadBlackCards();
  var httpServer = await HttpServer.bind(
      InternetAddress.anyIPv4, //'0.0.0.0',
      4041);

  httpServer.listen((HttpRequest req) {
    var endpointPath = req.uri.path;

    if (RegExp(r'^\/api.*').hasMatch(endpointPath)) {
      req.listen((data) {
        Map<String, dynamic> jsonData;
        try {
          jsonData = jsonDecode(String.fromCharCodes(data));
        } catch (err) {
          req
            ..response.statusCode = 500
            ..response.write('{"error":"body must be json"}');

          return;
        }

        if (RegExp(r'^\/api/create-bot').hasMatch(endpointPath)) {
          createBot(jsonData);
          req
            ..response.statusCode = 200
            ..response.write('{"success": true}');
        } else if (RegExp(r'^\/api/remove-bot').hasMatch(endpointPath)) {
          removeBot(jsonData);
          req
            ..response.statusCode = 200
            ..response.write('{"success": true}');
        } else {
          req
            ..response.statusCode = 404
            ..response.write('{"error":"endpoint not found"}');
        }
      });
    } else {
      req
        ..response.statusCode = 500
        ..response.write('{"error":"endpoint must start with /api "}');
    }

    req.response.close();
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

    var botHash = '${sessionToken}_$botId'.hashCode;
    var username = 'bot_$botHash';

    try {
      WebSocket socket = await WebSocket.connect('ws://$HOSTNAME/ws');
      var bot = Bot(username, socket)..init(sessionToken);

      if (botGroupedBySessionCode.containsKey(sessionToken)) {
        botGroupedBySessionCode[sessionToken].add(bot);
      } else {
        botGroupedBySessionCode[sessionToken] = [bot];
      }
    } catch (err) {
      printBotError(err.toString());
      return;
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
