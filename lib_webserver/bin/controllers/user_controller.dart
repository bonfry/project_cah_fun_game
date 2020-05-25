import '../sever_data.dart';

class UserController{

  static String getUsernameByToken(String token){
    var userDetails = ServerData.userConnections.values
        .firstWhere((uConn) => uConn.token == token);

    var username = ServerData.userConnections.keys
        .firstWhere((key) => ServerData.userConnections[key] == userDetails);

    return username;
  }

  static void removePlayer(String username){
    var userConnection = ServerData.userConnections[username];

    if(userConnection.socket != null){
      userConnection.socket.add('disconected');
    }

    var sessionWhereUserPlayed = ServerData.gameSessions
        .firstWhere((s) => s.playersDetailsMap.containsKey(username));

    sessionWhereUserPlayed.removePlayer(username);

    if(sessionWhereUserPlayed.playersDetailsMap.isEmpty){
      ServerData.gameSessions.remove(sessionWhereUserPlayed);
    }

    ServerData.userConnections.remove(username);
  }
}