import 'dart:convert';
import 'dart:io';

/// Class for managing requests from socketClient
class Request {
  ///Used form diversifying  client requests
  final String requestName;

  ///All data which client send to server (include user token also)
  final Map params;

  ///Socket object for identifying who launch message
  final WebSocket wsConnection;

  Request(this.requestName, this.params, {this.wsConnection});

  /// Constructor for get request from JSON map
  Request.fromJson(Map<String, dynamic> json, {this.wsConnection})
      : requestName = json['request_name'],
        params = json['params'];

  /// Convert to map for JSON encoding
  Map<String, dynamic> toJson() =>
      {'request_name': requestName, 'params': params};

  ///Use JSON style for print to console
  @override
  String toString() => jsonEncode(toJson());
}
