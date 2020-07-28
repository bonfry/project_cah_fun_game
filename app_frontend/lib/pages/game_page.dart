import 'dart:math';

import 'package:cah_common_values/card.dart' as cardModels;
import 'package:cah_common_values/enums/game_session_phase.dart';
import 'package:flutter/material.dart';
import 'package:projectcahfungame/game_session_manager.dart';
import 'package:projectcahfungame/models/game_session.dart';
import 'package:projectcahfungame/pages/winner_page.dart';
import 'package:projectcahfungame/widgets/game_card.dart';
import 'package:projectcahfungame/widgets/leaderboard.dart';
import 'package:projectcahfungame/widgets/white_card_deck.dart';

import '../game_session_scaffold.dart';
import '../session_data.dart';

class GamePage extends StatefulWidget {
  static const String route = '/game';
  final GameSession gameSession;

  const GamePage({Key key, @required this.gameSession}) : super(key: key);

  @override
  GamePageState createState() => GamePageState(gameSession);
}

class GamePageState extends State<GamePage> {
  //Game info
  final GameSession gameSession;
  String clientUsername;
  int _maxWhiteCardsSelected;
  cardModels.BlackCard blackCardChoose;
  List<cardModels.WhiteCard> _selectedWhiteCards = <cardModels.WhiteCard>[];
  List<cardModels.WhiteCard> whiteCards = [];
  bool isChoiceBlackTurn = false;
  bool isBlackKing = false;
  bool isHost = false;
  bool canICompile = false;

  //Screen size info
  double width = 0;
  double mediumScreenWidth = 768;

  GamePageState(this.gameSession);

  Future initGameVariables() async {

    blackCardChoose = gameSession.currentBlackCard;

    var user = await SessionData.getUser();
    clientUsername = user.username;
    isBlackKing = gameSession.blackKing == clientUsername;
    _maxWhiteCardsSelected = '<*>'.allMatches(blackCardChoose.text).length;
    whiteCards = gameSession.playersDetailMap[user.username].whiteCardDeck;

    blackCardChoose = gameSession.currentBlackCard;
    _maxWhiteCardsSelected = '<*>'.allMatches(blackCardChoose.text).length;
    whiteCards = gameSession.playersDetailMap[user.username].whiteCardDeck;
    isChoiceBlackTurn = gameSession.gamePhase == GameSessionPhase.CHOICE_BLACK;
    isBlackKing = clientUsername == gameSession.blackKing;
    isHost = clientUsername == gameSession.host;

    // if (oldPhase == GameSessionPhase.CHOICE_BLACK &&
    //     gameSession.gamePhase == GameSessionPhase.START_TURN) {
    //   _selectedWhiteCards =
    //       gameSession.playersDetailMap[user.username].whiteCardsChoose;
    // }

    width = MediaQuery.of(context).size.width;
    canICompile = _selectedWhiteCards.length == _maxWhiteCardsSelected;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: initGameVariables(),
        builder: (BuildContext context, AsyncSnapshot snap) {
          if (snap.connectionState != ConnectionState.done) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (clientUsername == null) {
            return Scaffold();
          }

          Widget scaffoldToRender = Scaffold();

          if (isChoiceBlackTurn && isBlackKing) {
            scaffoldToRender = showBlackCardChoice();
          } else if (isChoiceBlackTurn) {
            scaffoldToRender = showBlackCardChoice(sendResults: false);
          } else if (isBlackKing) {
            scaffoldToRender =
                showWaitingAlert('Attendi che gli altri giocatori scelgano');
          } else if (!isBlackKing) {
            scaffoldToRender = showWhiteChoice();
          }

          return ScaffoldForSignedPlayers(
              gameSession: gameSession,
              clientUsername: clientUsername,
              body: scaffoldToRender,
              appBarLeading: RaisedButton(
                  textColor: Colors.white,
                  color: Colors.blue,
                  child: Text(canICompile
                      ? "Compila carta nera"
                      : "Seleziona le carte"),
                  onPressed: canICompile
                      ? () {
                          GameSessionManager.chooseWhiteCards(
                              _selectedWhiteCards);
                        }
                      : null));
        });
  }

  Widget showWhiteChoice() {
    return Column(
      children: <Widget>[
        Expanded(
            child: Stack(
          children: <Widget>[
            Align(
              alignment: width > 734 || width < mediumScreenWidth
                  ? Alignment.center
                  : Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.all(20),
                constraints: BoxConstraints(maxWidth: 450),
                child: GameCard(
                  card: blackCardChoose,
                ),
              ),
            ),
            Visibility(
              visible: width > mediumScreenWidth,
              child: Positioned(
                  right: 20,
                  child: Container(
                    width: 200,
                    child: Leaderboard(
                      currentPlayerApplication: clientUsername,
                      blackKingPlayer: gameSession.blackKing,
                      playersMap: gameSession.playersDetailMap,
                    ),
                  )),
            )
          ],
        )),
        Text('Carte bianche'),
        WhiteCardDeck(
          whiteCardDeck: whiteCards,
          maxCardDeckToChoice: _maxWhiteCardsSelected,
          whiteCardSelected: _selectedWhiteCards,
          onChoose: (cards) {
            setState(() {
              _selectedWhiteCards = cards;
            });
          },
        )
      ],
    );
  }

  Widget showBlackCardChoice({bool sendResults = true}) {
    var textToShowOnTitle =
        sendResults ? 'Scegli la carta nera' : 'Le carte nere del turno';

    return Center(
        child: Container(
      constraints: BoxConstraints(maxWidth: 800),
      padding: EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: <Widget>[
          Text(
            textToShowOnTitle,
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
          ),
          Expanded(
            child: CustomScrollView(
              primary: false,
              slivers: <Widget>[
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverGrid.count(
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      crossAxisCount: 2,
                      children:
                          getMixedCompiledCards(sendResults: sendResults)),
                ),
              ],
            ),
          )
        ],
      ),
    ));
  }

  Widget createGameScreen(Widget body) {
    return Column(
      children: <Widget>[
        Expanded(
            child: Stack(
          children: <Widget>[
            body,
            Positioned(
              right: 20,
              child: Visibility(
                  visible: width > mediumScreenWidth,
                  child: Leaderboard(
                    currentPlayerApplication: clientUsername,
                    blackKingPlayer: gameSession.blackKing,
                    playersMap: gameSession.playersDetailMap,
                  )),
            )
          ],
        )),
        Text('Carte bianche'),
        WhiteCardDeck(
          whiteCardDeck: whiteCards,
          maxCardDeckToChoice: _maxWhiteCardsSelected,
          whiteCardSelected: _selectedWhiteCards,
          onChoose: (cards) {
            setState(() {
              _selectedWhiteCards = cards;
            });
          },
        )
      ],
    );
  }

  List<Widget> getMixedCompiledCards({bool sendResults = false}) {
    var outputCards = <Widget>[];
    var randomGenerator = Random();

    var players = gameSession.playersDetailMap.keys.where((username) {
      var isBlackKing = gameSession.blackKing != username;
      var hasSent = gameSession.playersDetailMap[username].hasSent;

      return isBlackKing && hasSent;
    }).toList();

    while (players.isNotEmpty) {
      var randomPlayerIndex =
          players.length > 1 ? randomGenerator.nextInt(players.length - 1) : 0;
      var playerName = players.removeAt(randomPlayerIndex);

      var cardsForCompile =
          gameSession.playersDetailMap[playerName].whiteCardsChoose;

      var compiledCard = GameCard.asCompleteBlackCard(
          card: blackCardChoose,
          cardsForCompleteBlackCard: cardsForCompile,
          onClick: sendResults
              ? () {
                  GameSessionManager.chooseBlackCard(playerName);
                }
              : null);

      outputCards.add(compiledCard);
    }

    return outputCards;
  }

  Widget showWaitingAlert(String message) {
    return Container(
      child: Stack(
        children: <Widget>[
          Center(
              child: Text(message,
                  style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: Color.fromRGBO(0, 0, 0, .5)))),
          Positioned(
              top: 100,
              right: 20,
              child: Container(
                width: 200,
                child: Leaderboard(
                  currentPlayerApplication: clientUsername,
                  blackKingPlayer: gameSession.blackKing,
                  playersMap: gameSession.playersDetailMap,
                ),
              )),
        ],
      ),
    );
  }

  void goToFinishGamePage() {
    Navigator.pushReplacementNamed(context, WinnerPage.route);
  }

  void finishGame() {
    GameSessionManager.finishGame();
  }
}
