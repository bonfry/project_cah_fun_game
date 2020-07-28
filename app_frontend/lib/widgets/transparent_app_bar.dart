import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:projectcahfungame/pages/login_page.dart';

import '../game_session_manager.dart';
import '../session_data.dart';

/// Transparent app bar used by Lobby and Game page
class TransparentAppBar extends AppBar {
  TransparentAppBar({
    Widget title,
    Widget leading,
    List<Widget> actions,
  }) : super(
            title: title,
            leading: leading,
            actions: actions,
            elevation: 0,
            backgroundColor: Colors.transparent,
            actionsIconTheme: IconThemeData(color: Colors.black));
}

enum ActionButtonType { IconButton, ListTile }

class KickPlayerActionButton extends StatelessWidget {
  final BuildContext context;
  final ActionButtonType buttonType;
  final List<String> playerUsernames;
  final String clientUsername;

  const KickPlayerActionButton({
    Key key,
    @required this.buttonType,
    @required this.context,
    @required this.playerUsernames,
    @required this.clientUsername,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget widgetToRender;

    if (buttonType == ActionButtonType.IconButton) {
      widgetToRender = IconButton(
        tooltip: 'Rimuovi giocatore',
        icon: Icon(MaterialCommunityIcons.account_remove),
        onPressed: () {
          showRemoveUserModal(clientUsername);
        },
      );
    } else if (buttonType == ActionButtonType.ListTile) {
      widgetToRender = ListTile(
        leading: Icon(MaterialCommunityIcons.account_remove),
        title: Text('Rimuovi giocatore'),
        onTap: () => showRemoveUserModal(clientUsername),
      );
    }

    return widgetToRender;
  }

  showRemoveUserModal(String playerUsername) {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Rimuovi gli utenti'),
            content: SingleChildScrollView(
                child: ListBody(
              children: playerUsernames
                  .where((username) => username != playerUsername)
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
  }
}

class LogoutActionButton extends StatelessWidget {
  final BuildContext context;
  final ActionButtonType buttonType;

  const LogoutActionButton(
      {Key key, @required this.buttonType, @required this.context})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget widgetToRender;

    if (buttonType == ActionButtonType.IconButton) {
      widgetToRender = IconButton(
          tooltip: 'Esci dalla sessione',
          icon: Icon(Icons.exit_to_app),
          onPressed: () => showLogoutConfirmModal());
    } else if (buttonType == ActionButtonType.ListTile) {
      widgetToRender = ListTile(
        leading: Icon(Icons.exit_to_app),
        title: Text('Esci dalla sessione'),
        onTap: () => showLogoutConfirmModal(),
      );
    }

    return widgetToRender;
  }

  showLogoutConfirmModal() {
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
                  Navigator.of(context).pushReplacementNamed(LoginPage.route);
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
  }
}

class GameRulesActionButton extends StatelessWidget {
  final BuildContext context;
  final ActionButtonType buttonType;
  final TextStyle titleStyle =
      const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, height: 2);

  const GameRulesActionButton(
      {Key key, @required this.context, @required this.buttonType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget widgetToRender;

    if (buttonType == ActionButtonType.IconButton) {
      widgetToRender = IconButton(
        tooltip: 'Regole del gioco',
        icon: Icon(MaterialCommunityIcons.gamepad),
        onPressed: showRules,
      );
    } else if (buttonType == ActionButtonType.ListTile) {
      widgetToRender = ListTile(
        leading: Icon(MaterialCommunityIcons.gamepad),
        title: Text('Regole del gioco'),
        onTap: showRules,
      );
    }

    return widgetToRender;
  }

  showRules() async {
    var jsonTextRules = await rootBundle.loadString('gamerules.json');
    Map<String, dynamic> jsonRules = jsonDecode(jsonTextRules);

    return showDialog<void>(
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
                  Text(jsonRules['pick2_rule_title'], style: titleStyle),
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
    );
  }
}

class BotManagerActionButton extends StatelessWidget {
  final BuildContext context;
  final ActionButtonType buttonType;
  final String sessionToken;
  final TextStyle titleStyle =
      const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, height: 2);

  const BotManagerActionButton({
    Key key,
    @required this.context,
    @required this.buttonType,
    @required this.sessionToken,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget widgetToRender;

    if (buttonType == ActionButtonType.IconButton) {
      widgetToRender = IconButton(
        tooltip: 'Aggiungi bot',
        icon: Icon(MaterialCommunityIcons.robot),
        onPressed: showBotGenerationModal,
      );
    } else if (buttonType == ActionButtonType.ListTile) {
      widgetToRender = ListTile(
        leading: Icon(MaterialCommunityIcons.robot),
        title: Text('Aggiungi bot'),
        onTap: showBotGenerationModal,
      );
    }
    return widgetToRender;
  }

  showBotGenerationModal() {
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
                      contentPadding: EdgeInsets.symmetric(horizontal: 15),
                      labelText: 'Numero bot da generare',
                      border: OutlineInputBorder()),
                ),
              ),
              actions: [
                FlatButton(
                  child: Text('CREA'),
                  onPressed: () async {
                    formState.currentState.save();
                    print('Devo aggiungere $botCount bot');
                    GameSessionManager.addBot(this.sessionToken, botCount)
                        .then((value) => Navigator.pop(context));
                  },
                ),
                FlatButton(
                  child: Text('CANCELLA'),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ));
  }
}
