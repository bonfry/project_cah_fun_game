import 'package:projectcahfungame/models/game_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class Leaderboard extends StatelessWidget {
  final String blackKingPlayer;
  final String currentPlayerApplication;
  final Map<String, PlayerDetail> playersMap;

  static const Icon _blackKingIcon = Icon(MaterialCommunityIcons.chess_king);
  static const Icon _hasSentIcon = Icon(
    MaterialCommunityIcons.check,
    color: Colors.lightGreenAccent,
  );

  const Leaderboard(
      {Key key,
      @required this.playersMap,
      @required this.currentPlayerApplication,
      @required this.blackKingPlayer})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    var playersOrderByScore = playersMap.keys.toList()
      ..sort((username1,username2){
        var userPoints1 = playersMap[username1].points;
        var userPoints2 = playersMap[username2].points;

        return userPoints1.compareTo(userPoints2)*-1;
      });
    

    return Card(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Leaderboard',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
            ),
            ...playersOrderByScore.sublist(0,5).map(createPlayerLabel),
            Divider(
              color: Colors.grey,
              thickness: 5,
            ),
            createPlayerLabel(currentPlayerApplication)
          ],
        ),
      ),
    );
  }

  Widget createPlayerLabel(String username){
    double iconOpacity =
    (playersMap[username].hasSent || blackKingPlayer == username)
        ? 1
        : 0;

    var iconToShow =
    blackKingPlayer == username ? _blackKingIcon : _hasSentIcon;

    return Container(
        padding: EdgeInsets.only(top: 10),
        child: Row(
          children: <Widget>[
            Opacity(
              opacity: iconOpacity,
              child: Padding(
                padding: EdgeInsets.only(right: 10),
                child: iconToShow,
              ),
            ),
            Text(username),
            Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  playersMap[username].points.toString(),
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.blue[700]),
                ))
          ],
        ));
  }
}
