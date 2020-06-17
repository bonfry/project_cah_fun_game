import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: double.maxFinite,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            InkWell(
                child: new Text('GitHub repo'),
                onTap: () =>
                    launch('https://github.com/bonfry/project_cah_fun_game')),
            Text(' | '),
            InkWell(
              child: new Text('Credits'),
              onTap: () => showCredits(context),
            ),
            Text(' | '),
            InkWell(
                child: new Text('Bonfry.com'),
                onTap: () => launch('https://bonfry.com'))
          ],
        ),
      ),
    );
  }

  void showCredits(BuildContext context) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text('Crediti'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('CAH42 per aver fornito le carte presenti nel gioco'),
                    Text('Bonfry.com per lo sviluppo dell\'app'),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('OK, CAPITO'),
                  onPressed: () => Navigator.pop(ctx),
                )
              ],
            ));
  }
}
