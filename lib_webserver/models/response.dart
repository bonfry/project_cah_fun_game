import 'dart:convert';

class Response{
  final Map<String,dynamic> body;
  final int requestHash;

  Response(this.body, {this.requestHash});

  String toJson(){
    var jsonMap = <String,dynamic>{
      'request_hash': requestHash,
      'body': body
    };

    return JsonEncoder().convert(jsonMap);
  }
}
