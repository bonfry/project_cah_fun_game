import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../models/card.dart';
import '../models/game_session.dart';
import '../sever_data.dart';

class CardController{
  static void loadCards(){
    var cardConfigFile = File('card_datasource/config.json');

    Map<String,dynamic> cardConfig = JsonDecoder().convert(cardConfigFile.readAsStringSync());
    var cardSets = cardConfig['card_sets'];

    var whiteCardsLoaded = <WhiteCard>[];
    var blackCardsLoaded = <BlackCard>[];

    for(var cardSet in cardSets){
      var whiteCards = getWhiteCardFromFile(cardSet['white_cards_file'], cardSet['code']);
      var blackCards = getBlackCardFromFile(cardSet['black_cards_file'], cardSet['code']);

      whiteCardsLoaded.addAll(whiteCards);
      blackCardsLoaded.addAll(blackCards);
    }

    ServerData.whiteCards = whiteCardsLoaded;
    ServerData.blackCards = blackCardsLoaded;

    print('sono state caricate ${whiteCardsLoaded.length} carte bianche e ${blackCardsLoaded.length} carte nere');
  }

  static List<WhiteCard> getWhiteCardFromFile(String filename, String setCode){
    var file = File('card_datasource/$filename');
    var cardDataSource = file.readAsStringSync().split('\n');

    var whiteCards = <WhiteCard>[];
    
    for(var i = 0; i < cardDataSource.length; i++){
      var whiteCard = WhiteCard('${setCode}_${i+1}', cardDataSource[i]);

      whiteCards.add(whiteCard);
    }

    return whiteCards;
  }

  static List<BlackCard> getBlackCardFromFile(String filename, String setCode){
    var file = File('card_datasource/$filename');
    var cardDataSource = file.readAsStringSync().split('\n');

    var blackCards = <BlackCard>[];

    for(var i = 0; i < cardDataSource.length; i++){
      var blackCard = BlackCard('${setCode}_${i+1}', cardDataSource[i]);

      blackCards.add(blackCard);
    }

    return blackCards;
  }

  static List<Card> mixCards(List<Card> cardsSource){
    var cardsContainer = List.of(cardsSource);
    var randomGenerator = Random();
    var cardsMixed = <Card>[];

    while(cardsContainer.isNotEmpty){
      var nextCardIndex = randomGenerator.nextInt(cardsContainer.length);
      var nextCard = cardsContainer.removeAt(nextCardIndex);
      cardsMixed.add(nextCard);
    }

    return cardsMixed;
  }

  static void giveCardsToPlayer(GameSession session){
    session.playersDetailsMap.values.forEach((playedDet){

      var whiteCardsOnHandCount = playedDet.whiteCardIdsOnHand.length;
      var cardsToGive = 10 - whiteCardsOnHandCount;
      var cardToGiveToPlayer = session.whiteCardIds
          .sublist(0, cardsToGive)
          .map((cardId) => cardId).toList();

      session.whiteCardIds.removeRange(0, cardsToGive);

      playedDet.whiteCardIdsOnHand.addAll(cardToGiveToPlayer);
    });
  }
}