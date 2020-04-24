import 'dart:convert';
import 'dart:io';

import 'content_type_table.dart';
import 'controllers/card_controller.dart';
import 'controllers/game_session_controller.dart';
import 'controllers/request_controller.dart';
import 'models/file_extension.dart';
import 'sever_data.dart';

void main() {
  CardController.loadCards();

  HttpServer.bind(InternetAddress.anyIPv4, 4040).then((HttpServer server) {
    print('[+]WebSocket listening at -- ws://localhost:4040');
    server.listen((HttpRequest request) {
      if (request.uri.path.contains('getCards')) {
        return manageCardRequest(request);
      } else if (request.uri.path.contains('ws')) {
        WebSocketTransformer.upgrade(request).then((socket) {
          socket.listen((data) {
            try {
              if (data.runtimeType != String) {
                throw Exception('Data must be a JSON string');
              }

              RequestController.parseRequest(data, socket);
            } catch (err) {
              socket.add('{"error":"$err"}');
            }
          });

          socket.done.then((_) {
            if (ServerData.userConnections.values
                    .where((uc) => uc.socket == socket)
                    .length !=
                1) {
              return;
            }

            var username = ServerData.userConnections.keys.firstWhere(
                (usr) => ServerData.userConnections[usr].socket == socket);

            var gameSession =
                GameSessionController.getSessionByUsername(username);

            gameSession.playersDetailsMap[username].online = false;
            RequestController.broadcastResponse(gameSession);
          });
        });
      } else {
        var filePath = request.uri.path == '/'
            ? 'app/index.html'
            : 'app${request.uri.path}';

        filePath = filePath
            .replaceAll(RegExp(r'#.*'), '')
            .replaceAll(RegExp(r'[?].*'), '');

        var file = File(filePath);

        if (file.existsSync()) {
          var fileContent = file.readAsBytesSync();
          request.response..statusCode = HttpStatus.accepted;

          var fileExtension = file.getFileExtension();
          var mimeType = contentTypeTable[fileExtension];

          try {
            request.response
              ..headers.add('Access-Control-Allow-Origin', '*')
              ..headers.add('Content-Type', mimeType)
              ..headers.add('Accept', mimeType)
              ..add(fileContent)
              ..close();
          } catch (err) {
            print(err);
          }
        } else {
          request.response
            ..statusCode = HttpStatus.notFound
            ..close();
        }
      }
    }, onError: (err) {
      print('[!]Error -- ${err.toString()}');
    });
  });
}

void manageCardRequest(HttpRequest request) {
  var cards = <String, dynamic>{
    'white_cards': ServerData.whiteCards.map((c) => c.toMap()).toList(),
    'black_cards': ServerData.blackCards.map((c) => c.toMap()).toList()
  };

  request.response
    ..headers.add('Access-Control-Allow-Origin', '*')
    ..statusCode = HttpStatus.accepted
    ..write(JsonEncoder().convert(cards))
    ..close();
}
