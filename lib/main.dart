import 'package:projectcahfungame/pages/lobby_page.dart';
import 'package:projectcahfungame/pages/login_page.dart';
import 'package:projectcahfungame/session_data.dart';
import 'package:flutter/material.dart';

import 'game_session_manager.dart';
import 'models/user.dart';

void main() {
  GameSessionManager.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Project CAH42 Online'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: SessionData.getUser(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          return LobbyPage();
        } else if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data == null) {
          return LoginPage();
        }

        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
    //return LoginPage();
  }
}
