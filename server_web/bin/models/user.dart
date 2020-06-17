// User's data who join in game session
import 'dart:io';

class UserConnectionDetails{
  final String token;
  final WebSocket socket;

  UserConnectionDetails({ this.token,this.socket});
}