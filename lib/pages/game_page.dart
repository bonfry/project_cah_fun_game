import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:projectcahfungame/game_session_manager.dart';
import 'package:projectcahfungame/models/card.dart';
import 'package:projectcahfungame/models/enums/game_session_phase.dart';
import 'package:projectcahfungame/models/game_session.dart';
import 'package:projectcahfungame/pages/login_page.dart';
import 'package:projectcahfungame/pages/winner_page.dart';
import 'package:projectcahfungame/widgets/game_card.dart';
import 'package:projectcahfungame/widgets/leaderboard.dart';
import 'package:projectcahfungame/widgets/white_card_deck.dart';

import '../main.dart';
import '../session_data.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key key}) : super(key: key);

  @override
  GamePageState createState() => GamePageState();
}

class GamePageState extends State<GamePage> {
  BlackCard blackCardChoose;
  List<WhiteCard> _selectedWhiteCards = <WhiteCard>[];
  List<WhiteCard> whiteCards = [];
  int _maxWhiteCardsSelected;
  GameSession gameSession;
  String currentUserInApplication = '';
  GamePageState();

  @override
  void initState() {
    super.initState();

    SessionData.getUser();

    gameSession = GameSessionManager.currentGameSession;
    blackCardChoose = gameSession.currentBlackCard;

    SessionData.getUser().then((user) {
      currentUserInApplication = user.username;
      setState(() {
        _maxWhiteCardsSelected = '<*>'.allMatches(blackCardChoose.text).length;
        whiteCards = gameSession.playersDetailMap[user.username].whiteCardDeck;
      });
    });

    GameSessionManager.onUpdate((session) async {
      var user = await SessionData.getUser();
      var oldPhase = gameSession.gamePhase;

      setState(() {
        gameSession = session;
        blackCardChoose = gameSession.currentBlackCard;
        _maxWhiteCardsSelected = '<*>'.allMatches(blackCardChoose.text).length;
        whiteCards = gameSession.playersDetailMap[user.username].whiteCardDeck;

        if (oldPhase == GameSessionPhase.CHOICE_BLACK &&
            session.gamePhase == GameSessionPhase.START_TURN) {
          _selectedWhiteCards =
              gameSession.playersDetailMap[user.username].whiteCardsChoose;
        } else if (oldPhase == GameSessionPhase.FINISH_GAME) {
          goToFinishGamePage();
        }
      });
    });

    GameSessionManager.onDisconnect(() {
      SessionData.setUser(null);

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (ctx) => LoginPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: SessionData.getUser().then((u) => u.username),
        builder: (BuildContext context, AsyncSnapshot<String> snap) {
          var isChoiceBlackTurn =
              gameSession.gamePhase == GameSessionPhase.CHOICE_BLACK;
          var isBlackKing = snap?.data == gameSession.blackKing;
          var isHost = snap.data == gameSession.host;
          bool canICompile =
              _selectedWhiteCards.length == _maxWhiteCardsSelected;

          Widget scaffoldToRender = Scaffold();

          if (isChoiceBlackTurn && isBlackKing) {
            scaffoldToRender = showBlackCardChoice();
          } else if (isChoiceBlackTurn) {
            scaffoldToRender = showBlackCardChoice(sendResults: false);
            // showWaitingAlert('Attendi la scelta della carta nera');
          } else if (isBlackKing) {
            scaffoldToRender =
                showWaitingAlert('Attendi che gli altri giocatori scelgano');
          } else if (!isBlackKing) {
            scaffoldToRender = showWhiteChoice();
          }

          return Scaffold(
            appBar: AppBar(
                elevation: 0,
                title: Visibility(
                    visible:
                        gameSession.gamePhase != GameSessionPhase.START_TURN,
                    child: RaisedButton(
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
                            : null)),
                brightness: Brightness.dark,
                backgroundColor: Colors.transparent,
                actions: <Widget>[
                  IconButton(
                    tooltip: 'Esci dalla sessione',
                    icon: Icon(Icons.exit_to_app),
                    onPressed: () {
                      showLogoutConfirmModal();
                    },
                    color: Colors.black,
                  ),
                  Visibility(
                    visible: snap.hasData && isHost,
                    child: IconButton(
                      tooltip: 'Rimuovi giocatore',
                      icon: Icon(MaterialCommunityIcons.account_remove),
                      onPressed: () {
                        showRemoveUserModal(snap.data);
                      },
                      color: Colors.black,
                    ),
                  ),
                  Visibility(
                    visible: isHost,
                    child: IconButton(
                      tooltip: 'Concludi partita',
                      icon: Icon(MaterialCommunityIcons.close),
                      color: Colors.black,
                      onPressed: finishGame,
                    ),
                  )
                ]),
            body: scaffoldToRender,
          );
        });
  }

  Widget showWhiteChoice() {
    return Column(
      children: <Widget>[
        Expanded(
            child: Stack(
          children: <Widget>[
            Center(
              child: Container(
                margin: EdgeInsets.all(20),
                constraints: BoxConstraints(maxWidth: 450),
                child: GameCard(
                  card: blackCardChoose,
                  onClick: () {
                    showLogoutConfirmModal();
                  },
                ),
              ),
            ),
            Positioned(
                right: 20,
                child: Leaderboard(
                  currentPlayerApplication: currentUserInApplication,
                  blackKingPlayer: gameSession.blackKing,
                  playersMap: gameSession.playersDetailMap,
                ))
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
              child: Leaderboard(
                currentPlayerApplication: currentUserInApplication,
                blackKingPlayer: gameSession.blackKing,
                playersMap: gameSession.playersDetailMap,
              )),
        ],
      ),
    );
  }

  showLogoutConfirmModal() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Disconnessione dalla partita'),
          content: SingleChildScrollView(
            child: Text('Sei sicuro di voler uscire?'),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('SI'),
              onPressed: exitFromSession,
            ),
            FlatButton(
              child: Text('NO'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  showRemoveUserModal(String playerUsername) {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Rimuovi gli utenti'),
            content: SingleChildScrollView(
                child: ListBody(
              children: gameSession.playersDetailMap.keys
                  .where((username) => username != playerUsername)
                  .map((username) => GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Color.fromRGBO(0, 0, 0, 0.5))),
                          margin: EdgeInsets.symmetric(vertical: 5),
                          padding: EdgeInsets.all(10),
                          child: Text(username),
                        ),
                        onTap: () {
                          GameSessionManager.removePlayer(username);
                          Navigator.of(context).pop();
                        },
                      ))
                  .toList(),
            )),
            actions: <Widget>[
              FlatButton(
                child: Text('CHIUDI'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void exitFromSession() {
    GameSessionManager.logoutFromGame();
    SessionData.setUser(null);
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => MyHomePage()));
  }

  void goToFinishGamePage() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (ctx) => WinnerPage()));
  }

  void finishGame() {
    GameSessionManager.finishGame();
  }
}
