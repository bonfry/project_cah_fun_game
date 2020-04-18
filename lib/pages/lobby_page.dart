import 'package:projectcahfungame/game_session_manager.dart';
import 'package:projectcahfungame/models/enums/game_session_phase.dart';
import 'package:projectcahfungame/models/game_session.dart';
import 'package:projectcahfungame/pages/game_page.dart';
import 'package:projectcahfungame/session_data.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class LobbyPage extends StatefulWidget {
  @override
  LobbyPageState createState() => LobbyPageState();
}

class LobbyPageState extends State<LobbyPage> {
  GameSession gameSession;

  @override
  void initState() {
    super.initState();
    gameSession = GameSessionManager.currentGameSession;

    GameSessionManager.onUpdate((GameSession session) {
      if (session.gamePhase == GameSessionPhase.LOBBY) {
        setState(() {
          gameSession = session;
        });
      } else if (session.gamePhase == GameSessionPhase.START_GAME ||
          session.gamePhase == GameSessionPhase.START_TURN) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (ctx) => GamePage()));
      }
    });
    GameSessionManager.onDisconnect(() => Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (ctx) => MyHomePage())));
  }

  @override
  Widget build(BuildContext context) {
    var userNameList = gameSession.playersDetailMap.keys.toList();

    return FutureBuilder<String>(
      future: SessionData.getUser().then((user) => user.username),
      builder: (BuildContext context, AsyncSnapshot<String> snap) {
        return Scaffold(
          body: Column(
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Lobby partita',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
                  )),
              Expanded(
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 500),
                    margin: EdgeInsets.all(20),
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: <Widget>[
                            Text(
                              'Codice sessione',
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.w700),
                            ),
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
                                      border:
                                          Border.all(color: Color(0xffdddddd))),
                                  child: SelectableText(
                                    gameSession.id,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListView(
                                children: List.generate(
                                    userNameList.length,
                                    (index) => Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Text(userNameList[index]),
                                        )),
                              ),
                            ),
                            Visibility(
                              visible:
                                  snap.hasData && snap.data == gameSession.host,
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: RaisedButton(
                                      child: Text('Inizia partita'),
                                      onPressed: () {
                                        GameSessionManager.initGame();
                                      },
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
