import 'package:cah_common_values/card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/user.dart';

class SessionData {
  static User _currentUser;
  static List<WhiteCard> whiteCards;
  static List<BlackCard> blackCards;

  static SharedPreferences _sharedPreferences;

  static Future<SharedPreferences> get sharedPreferences async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }

    return _sharedPreferences;
  }

  static Future<User> getUser() async {
    if (_currentUser == null) {
      _currentUser = await User.getInstance();
    }

    return _currentUser;
  }

  static setUser(User user) {
    _currentUser = user;
  }
}
