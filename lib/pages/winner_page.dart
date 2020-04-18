import 'package:projectcahfungame/game_session_manager.dart';
import 'package:projectcahfungame/pages/lobby_page.dart';
import 'package:flutter/material.dart';
import 'package:howler/howler.dart';

class WinnerPage extends StatefulWidget {
  @override
  WinnerPageState createState() => WinnerPageState();
}

class WinnerPageState extends State<WinnerPage> {
  String playerWinner;

  @override
  void initState() {
    super.initState();

    var howl = Howl(src: ['http://bonfrycah.ddns.net:4040/audio/win.mp3']);
    Future.delayed(Duration(seconds: 1)).then((value) {
      howl.play();
    });

    var playersOrderByPoint =
        List.of(GameSessionManager.currentGameSession.playersDetailMap.keys)
          ..sort((userA, userB) {
            var pointsUserA = GameSessionManager
                .currentGameSession.playersDetailMap[userA].points;
            var pointsUserB = GameSessionManager
                .currentGameSession.playersDetailMap[userB].points;

            return pointsUserA.compareTo(pointsUserB) * -1;
          });

    playerWinner = playersOrderByPoint[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Il vincitore è', style: TextStyle(fontSize: 20)),
          Text(playerWinner,
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: Color.fromRGBO(0, 0, 0, .5))),
          Padding(
              padding: EdgeInsets.all(100),
              child: RaisedButton(
                child: Text('Torna alla lobby'),
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (ctx) => LobbyPage()));
                },
              ))
        ],
      ),
    ));
  }
}
