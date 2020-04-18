import 'dart:io';

import 'bot_print_helper.dart';
import '../lib_webserver/models/request.dart';

void main() async {
  print('Inserisci i bot da generare');
  var botCount = int.tryParse(stdin.readLineSync());

  print('Inserisci codice sessione');
  var sessionCode = stdin.readLineSync();

  for (var i = 0; i < botCount; i++) {
    WebSocket socket;

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
    loginRequest.params['username'] = 'player_bot_$i';

    var loginRequestParsed = loginRequest.toString();
    printBotSocketOutput(loginRequestParsed, botId: i);

    socket.add(loginRequestParsed);

    socket.listen((data) {
      printBotSocketInput(data, botId: i);
    }, onError: (err) {
      printBotError('Errore Connessione Socket => $err', botId: i);
    });
  }
}
