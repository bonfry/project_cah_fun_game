import 'dart:async';

import 'sever_data.dart';

class PingManager{
  static void initAutomaticPing(){
    Timer.periodic(Duration(seconds:30), (timer) { 
      _pingAllClients();
    });
  }

  static Future _pingAllClients() async{

    ServerData.userConnections.values.forEach((user) { 
      user.socket.add('ping');
    });    
  }
}