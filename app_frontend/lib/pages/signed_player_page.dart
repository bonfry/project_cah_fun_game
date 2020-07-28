import 'package:cah_common_values/enums/game_session_phase.dart';
import 'package:flutter/material.dart';
import 'package:projectcahfungame/models/game_session.dart';
import 'package:projectcahfungame/pages/winner_page.dart';
import 'package:projectcahfungame/widgets/reconnection_warning_dialog.dart';

import '../game_session_manager.dart';
import '../session_data.dart';
import 'game_page.dart';
import 'lobby_page.dart';
import 'login_page.dart';

class SignedPlayerPage extends StatefulWidget {
  static const String route = '/signed';

  _SignedPlayerPageState createState() => _SignedPlayerPageState();
}

class _SignedPlayerPageState extends State<SignedPlayerPage> {
  GameSession gameSession;
  GlobalKey<NavigatorState> navigatorkey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    gameSession = GameSessionManager.currentGameSession;

    GameSessionManager.onSessionClose.listen((event) {
      SessionData.setUser(null);

      Navigator.pushReplacementNamed(context, LoginPage.route);
    });

    GameSessionManager.onSessionUpdate.listen((session) {
      setState(() {
        gameSession = session;
      });

      switch (session.gamePhase) {
        case GameSessionPhase.LOBBY:
          navigatorkey.currentState.pushReplacementNamed(LobbyPage.route);
          break;
        case GameSessionPhase.START_GAME:
        case GameSessionPhase.START_TURN:
        case GameSessionPhase.CHOICE_BLACK:
        case GameSessionPhase.CHOICE_WHITE:
        case GameSessionPhase.FINISH_TURN:
          navigatorkey.currentState.pushReplacementNamed(GamePage.route);
          break;
        case GameSessionPhase.FINISH_GAME:
          navigatorkey.currentState.pushReplacementNamed(WinnerPage.route);
          break;
      }
    });

    GameSessionManager.onConnectionLost.listen((_) {
      showDialog(
        context: context,
        builder: (context) => ReconnectionWarningDialog(),
      );
    });
    GameSessionManager.onConnectionRecoverd.listen((_) => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Navigator(
          key: navigatorkey,
      initialRoute: LobbyPage.route,
      onGenerateRoute: (RouteSettings settings) {
        WidgetBuilder builder;

        switch (settings.name) {
          case LoginPage.route:
            builder = (BuildContext _) => LoginPage();
            break;
          case LobbyPage.route:
            builder = (BuildContext _) => LobbyPage(
                  gameSession: gameSession,
                );
            break;
          case GamePage.route:
            builder = (BuildContext _) => GamePage(
                  gameSession: gameSession,
                );
            break;
          case WinnerPage.route:
            builder = (BuildContext _) => WinnerPage();
            break;
          default:
            throw Exception('Invalid route: ${settings.name}');
        }

        return MaterialPageRoute(builder: builder, settings: settings);
      },
    ));
  }
}
