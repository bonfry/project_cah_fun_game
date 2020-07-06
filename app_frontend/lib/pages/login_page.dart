import 'package:cah_common_values/enums/game_session_phase.dart';
import 'package:flutter/material.dart';
import 'package:projectcahfungame/card_helper.dart';
import 'package:projectcahfungame/game_session_manager.dart';
import 'package:projectcahfungame/pages/game_page.dart';
import 'package:projectcahfungame/widgets/error_alert.dart';
import 'package:projectcahfungame/widgets/footer.dart';

import 'lobby_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool canIJoinToSession = false;
  String errorMessage;

  String username;
  String sessionCode;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    GameSessionManager.onUpdate((session) {
      if (session.gamePhase == GameSessionPhase.LOBBY ||
          session.gamePhase == GameSessionPhase.FINISH_GAME) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (ctx) => LobbyPage()));
      } else if (session.gamePhase == GameSessionPhase.START_TURN ||
          session.gamePhase == GameSessionPhase.CHOICE_BLACK) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (ctx) => GamePage()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.all(15),
                      child: Text(
                        "Cards Against the Humanity",
                        style: TextStyle(fontSize: 25),
                      )),
                  Center(
                      child: Container(
                    constraints: BoxConstraints(maxWidth: 450),
                    margin: EdgeInsets.all(50),
                    child: Card(
                        child: Container(
                      padding: EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ErrorAlert(
                                margin: EdgeInsets.all(5),
                                message: errorMessage,
                              ),
                              Text(
                                "Login",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: TextFormField(
                                  maxLength: 15,
                                  decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 15),
                                      labelText: 'Username',
                                      border: OutlineInputBorder()),
                                  validator: (value) {
                                    if (value == null || value?.length == 0) {
                                      return 'Username non inserito';
                                    }

                                    return null;
                                  },
                                  onSaved: (value) {
                                    username = value;
                                  },
                                ),
                              ),
                              Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 15),
                                        labelText: 'Codice sessione',
                                        border: OutlineInputBorder()),
                                    onSaved: (value) {
                                      sessionCode = value;
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        canIJoinToSession = value.length > 0;
                                      });
                                    },
                                  )),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  RaisedButton(
                                    child: Text(canIJoinToSession
                                        ? 'Accedi a sessione'
                                        : 'Crea sessione'),
                                    onPressed: () {
                                      setState(() {
                                        errorMessage = null;
                                      });
                                      if (_formKey.currentState.validate()) {
                                        _formKey.currentState.save();
                                        loadCards().then((value) {
                                          if (GameSessionManager
                                              .isConnectedToServer) {
                                            manageLogin();
                                          } else {
                                            GameSessionManager.onConnection(
                                                manageLogin);
                                          }
                                        });
                                      }
                                    },
                                  ),
                                ],
                              )
                            ]),
                      ),
                    )),
                  )),
                ],
              ),
            ),
          ),
          Footer()
        ],
      ),
    );
  }

  void manageLogin() {
    if (canIJoinToSession) {
      GameSessionManager.signIn(username, gameSessionId: sessionCode);
    } else {
      GameSessionManager.signIn(username);
    }
  }
}
