import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:projectcahfungame/models/game_session.dart';

class Leaderboard extends StatelessWidget {
  final String blackKingPlayer;
  final String currentPlayerApplication;
  final Map<String, PlayerDetails> playersMap;

  const Leaderboard(
      {Key key,
      @required this.playersMap,
      @required this.currentPlayerApplication,
      @required this.blackKingPlayer})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var playersOrderByScore = playersMap.keys.toList()
      ..sort((username1, username2) {
        var userPoints1 = playersMap[username1].points;
        var userPoints2 = playersMap[username2].points;

        return userPoints1.compareTo(userPoints2) * -1;
      });

    var first5Players = playersOrderByScore.length > 5
        ? playersOrderByScore.sublist(0, 5)
        : playersOrderByScore;

    var first5PlayerLabels =
        first5Players.map((username) => _PlayerLeaderboardLabel(
              username: username,
              score: playersMap[username].points,
              hasSent: playersMap[username].hasSent,
              isBlackKing: blackKingPlayer == username,
            ));

    var clientPlayerLabel = _PlayerLeaderboardLabel(
      username: currentPlayerApplication,
      score: playersMap[currentPlayerApplication].points,
      isBlackKing: blackKingPlayer == currentPlayerApplication,
      hasSent: playersMap[currentPlayerApplication].hasSent,
    );

    return Card(
      child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Leaderboard',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              ...first5PlayerLabels,
              Visibility(
                  visible: playersOrderByScore.length > 5,
                  child: Divider(color: Colors.grey, thickness: 1)),
              Visibility(
                  visible: playersOrderByScore.length > 5,
                  child: clientPlayerLabel),
            ],
          )),
    );
  }
}

class _PlayerLeaderboardLabel extends StatelessWidget {
  final String username;
  final int score;
  final bool hasSent;
  final bool isBlackKing;

  static const Icon _blackKingIcon = Icon(MaterialCommunityIcons.chess_king);
  static const Icon _hasSentIcon = Icon(
    MaterialCommunityIcons.check,
    color: Colors.lightGreenAccent,
  );

  _PlayerLeaderboardLabel({
    this.username = '',
    this.score,
    this.hasSent = false,
    this.isBlackKing = false,
  });

  @override
  Widget build(BuildContext context) {
    final Icon currentIcon = isBlackKing ? _blackKingIcon : _hasSentIcon;

    return Row(
      children: <Widget>[
        Opacity(
          opacity: hasSent || isBlackKing ? 1 : 0,
          child: currentIcon,
        ),
        Expanded(
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                username,
                overflow: TextOverflow.ellipsis,
              )),
        ),
        Text(
          '$score',
          style:
              TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600),
        )
      ],
    );
  }
}
