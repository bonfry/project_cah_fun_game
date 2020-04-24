import 'enums/game_session_phase.dart';
import 'player_details.dart';
import 'player_iterator.dart';

//TODO: rimuovere giocatore dall'iteratore quando offline
class GameSession {
  final String id;

  List<String> whiteCardIds;
  Iterator<String> blackCardIdIterator;
  String currentBlackCardId;
  String host;
  String blackKing;
  Map<String, PlayerDetails> playersDetailsMap;
  PlayersIterator _playersIterator;
  GameSessionPhase phase;

  GameSession(this.id,
      {this.host,
      this.playersDetailsMap,
      this.phase = GameSessionPhase.LOBBY,
      this.blackKing,
      this.currentBlackCardId,
      this.whiteCardIds}) {
    playersDetailsMap ??= <String, PlayerDetails>{};
    _playersIterator = PlayersIterator(playersDetailsMap.keys);
  }

  String nextBlackKing({random = false}) {
    if (_playersIterator.length == 0) {
      throw Exception('No players found');
    }

    if (random) {
      _playersIterator.moveNextRandom();
    } else {
      _playersIterator.moveNext();
    }

    blackKing = _playersIterator.currentPlayer;

    return blackKing;
  }

  static GameSession parseMap(Map<String, dynamic> gameSession) {
    var playerDetailParsedMap = Map<String, PlayerDetails>();

    (gameSession['players'] as Map<String, Object>).keys.forEach((usrName) {
      playerDetailParsedMap[usrName] =
          PlayerDetails.parseMap(gameSession['players'][usrName]);
    });

    String host = gameSession['host'];
    String blackKing = gameSession['black_king'];

    return GameSession(gameSession['id'],
        phase: GameSessionPhase.values[gameSession['phase']],
        currentBlackCardId: gameSession['cur_black_card_id'],
        host: host,
        blackKing: blackKing,
        playersDetailsMap: playerDetailParsedMap);
  }

  Map<String, dynamic> toMap() {
    var playerMap = <String, dynamic>{};

    playersDetailsMap.keys
        .where((username) => playersDetailsMap[username].online)
        .forEach((username) {
      playerMap[username] = playersDetailsMap[username].toMap();
    });

    return {
      'id': id,
      'host': host,
      'black_king': blackKing,
      'phase': phase.index,
      'cur_black_card_id': currentBlackCardId,
      'players': playerMap,
    };
  }

  void addPlayer(String username) {
    playersDetailsMap[username] = PlayerDetails();
    _playersIterator.addPlayer(username);
  }

  void removePlayer(String username) {
    playersDetailsMap.remove(username);

    if (playersDetailsMap.keys.isEmpty) {
      return;
    }

    if (username == blackKing) {
      nextBlackKing();
    }

    _playersIterator.removePlayer(username);

    if (username == host) {
      host = blackKing;
    }
  }
}
