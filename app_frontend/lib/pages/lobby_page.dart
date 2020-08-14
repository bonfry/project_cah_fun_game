import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projectcahfungame/game_session_manager.dart';
import 'package:projectcahfungame/models/game_session.dart';
import 'package:projectcahfungame/session_data.dart';

class LobbyPage extends StatefulWidget {
  static const String route = '/lobby';
  final GameSession gameSession;

  const LobbyPage({Key key, @required this.gameSession}) : super(key: key);

  @override
  LobbyPageState createState() => LobbyPageState(gameSession);
}

class LobbyPageState extends State<LobbyPage> {
  final GameSession gameSession;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  LobbyPageState(this.gameSession);

  @override
  Widget build(BuildContext context) {
    var userNameList = gameSession.playersDetailMap.keys.toList();

    return FutureBuilder<String>(
      future: SessionData.getUser().then((user) => user.username),
      builder: (BuildContext context, AsyncSnapshot<String> snap) {
        return Scaffold(
          key: scaffoldKey,
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
                                child: GestureDetector(
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8)),
                                        border: Border.all(
                                            color: Color(0xffdddddd))),
                                    child: Text(
                                      gameSession.id,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  onTap: () {
                                    Clipboard.setData(
                                        ClipboardData(text: gameSession.id));

                                    scaffoldKey.currentState
                                        .showSnackBar(SnackBar(
                                      content: Text('Codice sessione copiato'),
                                    ));
                                  },
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
