import 'enums/game_session_phase.dart';
import 'player_details.dart';
import 'player_iterator.dart';

class GameSession{
  final String id;
  List<String> whiteCardIds;
  Iterator<String> blackCardIdIterator;
  String currentBlackCardId;
  String host;
  String blackKing;
  Map<String, PlayerDetails> playersDetailsMap;
  PlayersIterator _playersIterator;
  GameSessionPhase phase;

  GameSession(this.id, {this.host,this.playersDetailsMap, this.phase = GameSessionPhase.LOBBY}){
    playersDetailsMap ??= <String,PlayerDetails>{};
    _playersIterator = PlayersIterator(playersDetailsMap.keys);
  }

  String nextBlackKing({random = false}){
    if(_playersIterator.length == 0){
      throw Exception('No players found');
    }

    if(random){
      _playersIterator.moveNextRandom();
    }else{
      _playersIterator.moveNext();
    }

    blackKing = _playersIterator.currentPlayer;

    return blackKing;
  }



  Map<String, dynamic> toMap(){

    var playerMap = <String, dynamic>{};

    playersDetailsMap.keys.forEach((username){
      playerMap[username] = playersDetailsMap[username].toMap();
    });

    return {
      'id':id,
      'host':host,
      'black_king':blackKing,
      'phase': phase.index,
      'cur_black_card_id':currentBlackCardId,
      'players':playerMap,
    };
  }

  void addPlayer(String username){
    playersDetailsMap[username] = PlayerDetails();
    _playersIterator.addPlayer(username);
  }

  void removePlayer(String username){
    playersDetailsMap.remove(username);

    if(playersDetailsMap.keys.isEmpty){
      return;
    }

    if(username == blackKing){
      nextBlackKing();
    }

    _playersIterator.removePlayer(username);

    if(username == host){
      host = blackKing;
    }
  }
}
