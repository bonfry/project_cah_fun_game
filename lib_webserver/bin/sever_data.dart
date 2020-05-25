import 'package:cah_common_values/card.dart';

import 'models/game_session.dart';
import 'models/user.dart';

// Server data container
class ServerData {
  static Map<String, UserConnectionDetails> userConnections =
      <String, UserConnectionDetails>{};
  static List<GameSession> gameSessions = <GameSession>[];
  static List<WhiteCard> whiteCards = <WhiteCard>[];
  static List<BlackCard> blackCards = <BlackCard>[];
}
