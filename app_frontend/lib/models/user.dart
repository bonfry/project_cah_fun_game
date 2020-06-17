import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:projectcahfungame/session_data.dart';

const String USER_SHARED_PREFERENCES_LABEL = 'user_config';

class User {
  final String username;
  final String token;

  User({@required this.username, this.token});

  Map<String, String> toMap() {
    return {'username': username, 'user_token': token};
  }

  static User parseUser(Map<String, String> userDataMap) {
    return User(
        username: userDataMap['username'], token: userDataMap['user_token']);
  }

  static Future<User> getInstance() async {
    var sharedPrefs = await SessionData.sharedPreferences;
    User user;

    if (!sharedPrefs.containsKey(USER_SHARED_PREFERENCES_LABEL)) {
      return user;
    }

    var userConfigText = sharedPrefs.getString(USER_SHARED_PREFERENCES_LABEL);
    var jsonMap = JsonDecoder().convert(userConfigText);

    if (jsonMap.containsKey('username') && jsonMap.containsKey('user_token')) {
      user = User.parseUser(jsonMap);
    }

    return user;
  }

  static User login(String username, String token, {bool saveLogin = false}) {
    User user;

    if (username != null && token != null) {
      user = User(username: username, token: token);

      if (saveLogin) {
        var jsonText = JsonEncoder().convert(user.toMap());

        SessionData.sharedPreferences.then((sharedPrefs) =>
            sharedPrefs.setString(USER_SHARED_PREFERENCES_LABEL, jsonText));
      }
    }

    return user;
  }
}
