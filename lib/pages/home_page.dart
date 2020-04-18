import 'package:projectcahfungame/models/card.dart';
import 'package:projectcahfungame/session_data.dart';
import 'package:projectcahfungame/widgets/game_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'game_page.dart';

class HomePage extends StatefulWidget {
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedBlackCardIndex;

  @override
  Widget build(BuildContext context) {
    var titleStyle = TextStyle(fontSize: 25, fontWeight: FontWeight.w700);

    return FutureBuilder<List<BlackCard>>(
      initialData: [],
      future: Future.value(SessionData.blackCards),
      builder: (context, snapshot) {
        return Scaffold(
          body: Column(
            children: <Widget>[
              Text(
                'Carte nere',
                style: titleStyle,
              ),
              Expanded(
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data.length,
                      itemBuilder: (ctx, index) {
                        bool isSelected = index == _selectedBlackCardIndex;

                        return Container(
                          margin: EdgeInsets.all(10),
                          child: GameCard(
                            isSelected: isSelected,
                            onClick: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => GamePage()));
                            },
                            card: snapshot.data[index],
                          ),
                        );
                      }))
            ],
          ),
        );
      },
    );
  }
}
