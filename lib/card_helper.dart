import 'dart:async';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'package:projectcahfungame/session_data.dart';

import 'models/card.dart';

Future loadCards() {
  var completer = Completer();
  HttpRequest.getString("http://bonfrycah.ddns.net:4040/getCards")
      .then((value) {
    var cardFromResponse = JsonDecoder().convert(value);

    SessionData.whiteCards = (cardFromResponse['white_cards'] as List)
        .map((c) => WhiteCard(c['id'], c['text']))
        .toList();

    SessionData.blackCards = (cardFromResponse['black_cards'] as List)
        .map((c) => BlackCard(c['id'], c['text']))
        .toList();

    completer.complete();
  });

  return completer.future;
}
