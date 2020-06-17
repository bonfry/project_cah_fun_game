import 'package:cah_common_values/enums/game_session_phase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:projectcahfungame/models/game_session.dart';
import 'package:projectcahfungame/widgets/leaderboard.dart';
import 'package:projectcahfungame/widgets/transparent_app_bar.dart';

import 'game_session_manager.dart';

class ScaffoldForSignedPlayers extends StatelessWidget {
  final Widget body;
  final double mediumScreenWidth = 768;
  final GameSession gameSession;
  final String clientUsername;
  final Widget appBarLeading;

  ScaffoldForSignedPlayers(
      {Key key,
      this.body,
      @required this.gameSession,
      this.clientUsername,
      this.appBarLeading})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var _scaffoldKeyState = GlobalKey<ScaffoldState>();

    bool isHost = gameSession.host == clientUsername;

    return Scaffold(
      key: _scaffoldKeyState,
      appBar: TransparentAppBar(
          title: appBarLeading,
          actions: width > mediumScreenWidth
              ? <Widget>[
                  GameRulesActionButton(
                    context: context,
                    buttonType: ActionButtonType.IconButton,
                  ),
                  LogoutActionButton(
                    context: context,
                    buttonType: ActionButtonType.IconButton,
                  ),
                  Visibility(
                      visible: clientUsername != null && isHost,
                      child: KickPlayerActionButton(
                        buttonType: ActionButtonType.IconButton,
                        context: context,
                        playerUsernames:
                            gameSession.playersDetailMap.keys.toList(),
                        clientUsername: clientUsername,
                      )),
                  Visibility(
                    visible: isHost &&
                        gameSession.gamePhase != GameSessionPhase.LOBBY,
                    child: IconButton(
                      tooltip: 'Concludi partita',
                      icon: Icon(MaterialCommunityIcons.close),
                      color: Colors.black,
                      onPressed: finishGame,
                    ),
                  ),
                  Visibility(
                    visible: isHost,
                    child: BotManagerActionButton(
                      context: context,
                      buttonType: ActionButtonType.IconButton,
                    ),
                  )
                ]
              : <Widget>[
                  IconButton(
                    icon: Icon(Icons.menu),
                    color: Colors.black,
                    onPressed: () {
                      _scaffoldKeyState.currentState.openEndDrawer();
                    },
                  )
                ]),
      endDrawer: width > mediumScreenWidth
          ? null
          : Drawer(
              child: Container(
                  child: ListView(
              children: <Widget>[
                Visibility(
                  visible: gameSession.gamePhase != GameSessionPhase.LOBBY,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Leaderboard(
                      currentPlayerApplication: clientUsername,
                      blackKingPlayer: gameSession.blackKing,
                      playersMap: gameSession.playersDetailMap,
                    ),
                  ),
                ),
                GameRulesActionButton(
                  buttonType: ActionButtonType.ListTile,
                  context: context,
                ),
                LogoutActionButton(
                  buttonType: ActionButtonType.ListTile,
                  context: context,
                ),
                Visibility(
                  visible: clientUsername != null && isHost,
                  child: KickPlayerActionButton(
                    buttonType: ActionButtonType.ListTile,
                    context: context,
                    playerUsernames: gameSession.playersDetailMap.keys.toList(),
                    clientUsername: clientUsername,
                  ),
                ),
                Visibility(
                  visible:
                      isHost && gameSession.gamePhase != GameSessionPhase.LOBBY,
                  child: ListTile(
                    title: Text('Concludi partita'),
                    leading: Icon(MaterialCommunityIcons.close),
                    onTap: finishGame,
                  ),
                ),
                Visibility(
                  visible: isHost,
                  child: BotManagerActionButton(
                    context: context,
                    buttonType: ActionButtonType.ListTile,
                  ),
                ),
              ],
            ))),
      body: body,
    );
  }

  void finishGame() {
    GameSessionManager.finishGame();
  }
}
