import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:projectcahfungame/session_data.dart';

const String USER_SHARED_PREFERENCES_LABEL = 'user_config';

class User {
  static User _loggedUser;

  final String username;
  final String token;

  User._internal({@required this.username, this.token});

  User.fromJson(Map<String, dynamic> userDataMap) : 
    username =  userDataMap['username'] as String,
    token =  userDataMap['user_token'] as String;

  factory User(){
    return _loggedUser;
  }

  Map<String, dynamic> toJson() {
    return {'username': username, 'user_token': token};
  }



  static Future<User> getInstance() async {
    var sharedPrefs = await SessionData.sharedPreferences;
    User user = _loggedUser;

    if (user != null || !sharedPrefs.containsKey(USER_SHARED_PREFERENCES_LABEL)) {
      return user;
    }

    var userConfigText = sharedPrefs.getString(USER_SHARED_PREFERENCES_LABEL);
    var jsonMap = jsonDecode(userConfigText);

    if (jsonMap.containsKey('username') && jsonMap.containsKey('user_token')) {
      user = User.fromJson(jsonMap);
      _loggedUser = user;
    }

    return user;
  }

  static User login(String username, String token, {bool saveLogin = true}) {
    if (username != null && token != null) {
      _loggedUser = User._internal(username: username, token: token);

      if (saveLogin) {
        var jsonText =jsonEncode(_loggedUser);

        SessionData.sharedPreferences.then((sharedPrefs) =>
            sharedPrefs.setString(USER_SHARED_PREFERENCES_LABEL, jsonText));
      }
    }

    return _loggedUser;
  }
}
