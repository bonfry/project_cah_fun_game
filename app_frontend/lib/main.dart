import 'package:flutter/material.dart';
import 'package:projectcahfungame/pages/login_page.dart';
import 'package:projectcahfungame/pages/signed_player_page.dart';

import 'game_session_manager.dart';

void main() {
  GameSessionManager.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cards Against The Humanity',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //home: MyHomePage(title: 'Project CAH42 Online'),

      initialRoute: LoginPage.route,
      routes: {
        SignedPlayerPage.route: (BuildContext context) => SignedPlayerPage(),
        LoginPage.route: (BuildContext context) => LoginPage() 
      },
    );
  }
}
