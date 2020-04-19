import 'dart:convert';
import 'dart:io';

class Request {
  final String requestName;
  final Map<String, dynamic> params;
  final WebSocket wsConnection;

  Request(this.requestName, this.params, {this.wsConnection});

  static Request parseJson(Map<String, dynamic> data, {WebSocket socket}) {
    String requestName = data['request_name'];
    Map<String, dynamic> params = data['params'];

    var request = Request(requestName, params, wsConnection: socket);

    return request;
  }

  Map<String, dynamic> toMap() {
    return {'request_name': requestName, 'params': params};
  }

  @override
  String toString() {
    return JsonEncoder().convert(toMap());
  }
}

class RequestName {
  static const String SIGN_IN_REQUEST = 'signIn';
  static const String INIT_GAME_REQUEST = 'initGame';
  static const String SEND_WHITE_CARDS_REQUEST = 'sendWhiteCards';
  static const String SELECT_BLACK_CARD_REQUEST = 'selectBlackCard';
  static const String FINISH_GAME_REQUEST = 'finishGame';
  static const String REMOVE_PLAYER_REQUEST = 'removePlayer';
}
