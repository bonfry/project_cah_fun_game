import 'package:cah_common_values/card.dart' as cardModel;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class GameCard extends StatelessWidget {
  final cardModel.Card card;
  final VoidCallback onClick;
  final bool isSelected;
  final bool showCompletedBlackCard;
  final List<cardModel.WhiteCard> cardsForCompleteBlackCard;

  const GameCard(
      {Key key, @required this.card, this.onClick, this.isSelected = false})
      : showCompletedBlackCard = false,
        cardsForCompleteBlackCard = null,
        super(key: key);

  const GameCard.asCompleteBlackCard(
      {Key key,
      @required this.card,
      this.isSelected = false,
      this.onClick,
      @required this.cardsForCompleteBlackCard})
      : showCompletedBlackCard = true,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    int wordsRequired = 0;

    if (card.runtimeType == cardModel.BlackCard) {
      textColor = Colors.white;
      backgroundColor = Colors.black;
      wordsRequired = (card as cardModel.BlackCard).whiteCardsAllowed;
    } else {
      textColor = Colors.black;
      backgroundColor = Colors.white;
    }

    return GestureDetector(
      onTap: onClick,
      onLongPress: () => showFullCardText(context),
      child: AspectRatio(
          aspectRatio: 1,
          child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: isSelected
                      ? Border.all(color: Colors.amber, width: 3)
                      : null,
                  color: backgroundColor,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.7),
                      blurRadius: 4,
                    )
                  ]),
              child: Text(
                !showCompletedBlackCard
                    ? card.toString()
                    : (card as cardModel.BlackCard)
                        .compile(cardsForCompleteBlackCard)
                        .toString(),
                textAlign: TextAlign.start,
                maxLines: 10,
                style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 15),
              ))),
    );
  }

  void showFullCardText(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text('Info carta'),
              content: Text(!showCompletedBlackCard
                  ? card.toString()
                  : (card as cardModel.BlackCard)
                      .compile(cardsForCompleteBlackCard)
                      .toString()),
              actions: <Widget>[
                FlatButton(
                  child: Text('OK CAPITO'),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ));
  }
}
