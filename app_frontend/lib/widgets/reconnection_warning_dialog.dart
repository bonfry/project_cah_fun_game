import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ReconnectionWarningDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        content: Container(
            child: Row(
      children: [
        CircularProgressIndicator(),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text('Riconnessione alla partita in corso',
                maxLines: 3),
          ),
        )
      ],
    )));
  }
}
