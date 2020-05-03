import 'dart:convert';
import 'dart:io';

import 'package:cah_common_values/card.dart';

class CardController {
  static List<BlackCard> loadBlackCards() {
    var cardConfigFile = File('card_datasource/config.json');

    Map<String, dynamic> cardConfig =
        JsonDecoder().convert(cardConfigFile.readAsStringSync());
    var cardSets = cardConfig['card_sets'];

    var blackCardsLoaded = <BlackCard>[];

    for (var cardSet in cardSets) {
      var blackCards =
          getBlackCardFromFile(cardSet['black_cards_file'], cardSet['code']);

      blackCardsLoaded.addAll(blackCards);
    }

    return blackCardsLoaded;
  }

  static List<BlackCard> getBlackCardFromFile(String filename, String setCode) {
    var file = File('card_datasource/$filename');
    var cardDataSource = file.readAsStringSync().split('\n');

    var blackCards = <BlackCard>[];

    for (var i = 0; i < cardDataSource.length; i++) {
      var blackCard = BlackCard('${setCode}_${i + 1}', cardDataSource[i]);

      blackCards.add(blackCard);
    }

    return blackCards;
  }
}
