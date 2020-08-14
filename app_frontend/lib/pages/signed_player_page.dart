import 'dart:convert';

import 'package:cah_common_values/enums/game_session_phase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:projectcahfungame/models/game_session.dart';
import 'package:projectcahfungame/models/user.dart';
import 'package:projectcahfungame/pages/winner_page.dart';
import 'package:projectcahfungame/widgets/appbar_action.dart';
import 'package:projectcahfungame/widgets/leaderboard.dart';
import 'package:projectcahfungame/widgets/reconnection_warning_dialog.dart';
import 'package:projectcahfungame/widgets/transparent_app_bar.dart';

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
  final double mediumScreenWidth = 768;
  GlobalKey<NavigatorState> navigatorkey = GlobalKey<NavigatorState>();
  final _scaffoldKeyState = GlobalKey<ScaffoldState>();

  String clientUsername;
  bool isHost = false;
  bool isGamePhase = false;

  @override
  void initState() {
    super.initState();

    GameSessionManager.onSessionClose.listen((event) {
      SessionData.setUser(null);

      Navigator.pushReplacementNamed(context, LoginPage.route);
    });

    GameSessionManager.onSessionUpdate.listen((session) {
      gameSession = session;

      gameSession = GameSessionManager.currentGameSession;

      setState(() {
        clientUsername = User().username;
        isHost = gameSession.host == clientUsername;
      });

      switch (session.gamePhase) {
        case GameSessionPhase.LOBBY:
          isGamePhase = false;
          navigatorkey.currentState.pushReplacementNamed(LobbyPage.route);
          break;
        case GameSessionPhase.START_GAME:
        case GameSessionPhase.START_TURN:
        case GameSessionPhase.CHOICE_BLACK:
        case GameSessionPhase.CHOICE_WHITE:
        case GameSessionPhase.FINISH_TURN:
          isGamePhase = true;
          navigatorkey.currentState.pushReplacementNamed(GamePage.route);
          break;
        case GameSessionPhase.FINISH_GAME:
          isGamePhase = false;
          navigatorkey.currentState.pushReplacementNamed(WinnerPage.route);
          break;
      }

      setState(() {});
    });

    GameSessionManager.onConnectionLost.listen((_) {
      showDialog(
        context: context,
        builder: (context) => ReconnectionWarningDialog(),
      );
    });
    GameSessionManager.onConnectionRecoverd.listen((_) {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    var clientWidth = MediaQuery.of(context).size.width;

    if(gameSession == null){
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator()
        ),
      );
    }

    List<AppbarAction> appbarActions = [
      AppbarAction(
          buttonText: 'Regole del gioco',
          buttonIcon: MaterialCommunityIcons.gamepad,
          onTap: () {
            TextStyle titleStyle =
                TextStyle(fontWeight: FontWeight.bold, fontSize: 20, height: 2);
            rootBundle
                .loadString('gamerules.json')
                .then((json) => jsonDecode(json))
                .then((jsonRules) => showDialog<void>(
                      context: context,
                      barrierDismissible: false, // user must tap button!
                      builder: (BuildContext context) {
                        return AlertDialog(
                            content: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    jsonRules['base_rule_title'],
                                    style: titleStyle,
                                  ),
                                  Text(jsonRules['base_rule_text']),
                                  Text(jsonRules['pick2_rule_title'],
                                      style: titleStyle),
                                  Text(jsonRules['pick2_rule_text']),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('OK, CAPITO'),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ]);
                      },
                    ));
          }),
      AppbarAction(
          buttonIcon: Icons.exit_to_app,
          buttonText: 'Esci dalla sessione',
          onTap: () {
            return showDialog<void>(
              context: context,
              barrierDismissible: false, // user must tap button!
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Disconnessione dalla partita'),
                  content: SingleChildScrollView(
                    child: Text('Sei sicuro di voler uscire?'),
                  ),
                  actions: <Widget>[
                    FlatButton(
                        child: Text('SI'),
                        onPressed: () {
                          GameSessionManager.logoutFromGame();
                          Navigator.of(context)
                              .pushReplacementNamed(LoginPage.route);
                        }),
                    FlatButton(
                      child: Text('NO'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }),
      AppbarAction(
          visible: isHost,
          buttonIcon: MaterialCommunityIcons.robot,
          buttonText: 'Aggiungi bot',
          onTap: () {
            final formState = GlobalKey<FormState>();
            int botCount;

            return showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                      title: Text('Inserisci giocatori bot'),
                      content: Form(
                        key: formState,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          onSaved: (value) {
                            botCount = int.parse(value);
                          },
                          decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 15),
                              labelText: 'Numero bot da generare',
                              border: OutlineInputBorder()),
                        ),
                      ),
                      actions: [
                        FlatButton(
                          child: Text('CREA'),
                          onPressed: () async {
                            formState.currentState.save();
                            GameSessionManager.addBot(gameSession.id, botCount)
                                .then((value) => Navigator.pop(context));
                          },
                        ),
                        FlatButton(
                          child: Text('CANCELLA'),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    ));
          }),
      AppbarAction(
          visible: clientUsername != null && isHost,
          buttonIcon: MaterialCommunityIcons.account_remove,
          buttonText: 'Rimuovi giocatore',
          onTap: () {
            return showDialog<void>(
                context: context,
                barrierDismissible: false, // user must tap button!
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Rimuovi gli utenti'),
                    content: SingleChildScrollView(
                        child: ListBody(
                      children: gameSession.playersDetailMap.keys
                          .toList()
                          .where((username) => username != clientUsername)
                          .map((username) => GestureDetector(
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Color.fromRGBO(0, 0, 0, 0.5))),
                                  margin: EdgeInsets.symmetric(vertical: 5),
                                  padding: EdgeInsets.all(10),
                                  child: Text(username),
                                ),
                                onTap: () {
                                  GameSessionManager.removePlayer(username);
                                  Navigator.of(context).pop();
                                },
                              ))
                          .toList(),
                    )),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('CHIUDI'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                });
          }),
      AppbarAction(
          visible: isHost && gameSession.gamePhase != GameSessionPhase.LOBBY,
          buttonIcon: MaterialCommunityIcons.close,
          buttonText: 'Concludi partita',
          onTap: finishGame),
    ];

    return Scaffold(
        appBar: TransparentAppBar(
            actions: clientWidth > mediumScreenWidth
                ? appbarActions.toIconButtonList()
                : <Widget>[
                    IconButton(
                      icon: Icon(Icons.menu),
                      color: Colors.black,
                      onPressed: () {
                        _scaffoldKeyState.currentState.openEndDrawer();
                      },
                    )
                  ]),
        endDrawer: clientWidth > mediumScreenWidth
            ? null
            : Drawer(
                child: Container(
                    child: ListView(
                children: <Widget>[
                  Visibility(
                    visible: gameSession.gamePhase != GameSessionPhase.LOBBY,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Leaderboard(
                        currentPlayerApplication: clientUsername,
                        blackKingPlayer: gameSession.blackKing,
                        playersMap: gameSession.playersDetailMap,
                      ),
                    ),
                  ),
                  ...appbarActions.toDraweButtonList()
                ],
              ))),
        body: Navigator(
          key: navigatorkey,
          initialRoute: LobbyPage.route,
          onGenerateRoute: generateRoute,
        ));
  }

  void finishGame() {
    GameSessionManager.finishGame();
  }

  Route generateRoute(RouteSettings settings) {
    WidgetBuilder builder;

    switch (settings.name) {
      case SignedPlayerPage.route:
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
  }
}
