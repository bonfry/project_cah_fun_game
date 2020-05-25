import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:cah_common_values/card.dart';
import 'package:projectcahfungame/session_data.dart';

import 'game_session_manager.dart';

Future loadCards() {
  var completer = Completer();
  HttpRequest.getString("http://$HOSTNAME/api/getCards").then((value) {
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
