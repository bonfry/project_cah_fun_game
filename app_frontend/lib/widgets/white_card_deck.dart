import 'package:cah_common_values/card.dart';
import 'package:flutter/material.dart';

import 'game_card.dart';

typedef void WhiteCardChooseCallback(List<WhiteCard> whiteCardChoose);

class WhiteCardDeck extends StatelessWidget {
  final List<WhiteCard> whiteCardDeck;
  final List<WhiteCard> whiteCardSelected;
  final int maxCardDeckToChoice;
  final WhiteCardChooseCallback onChoose;

  WhiteCardDeck(
      {this.whiteCardDeck,
      this.whiteCardSelected,
      @required this.maxCardDeckToChoice,
      this.onChoose});

  @override
  Widget build(BuildContext context) {
    var whiteCardsBuilt = whiteCardDeck.map(buildGameCard).toList();

    return Container(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: whiteCardsBuilt,
      ),
    );
  }

  Widget buildGameCard(WhiteCard wCard) {
    int cardChoosePosition = whiteCardSelected.indexOf(wCard);
    bool isThisCardSelected = cardChoosePosition > -1;

    return Container(
        padding: EdgeInsets.all(15),
        child: Stack(
          children: <Widget>[
            GameCard(
              isSelected: isThisCardSelected,
              card: wCard,
              onClick: () {
                if (isThisCardSelected) {
                  whiteCardSelected.remove(wCard);
                  onChoose(whiteCardSelected);
                } else if (whiteCardSelected.length < maxCardDeckToChoice) {
                  whiteCardSelected.add(wCard);
                  onChoose(whiteCardSelected);
                }
              },
            ),
            Visibility(
                visible: cardChoosePosition != -1,
                child: Positioned(
                  bottom: 20,
                  right: 20,
                  child: Container(
                    child: Text(
                      '${cardChoosePosition + 1}',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                  ),
                ))
          ],
        ));
  }
}
