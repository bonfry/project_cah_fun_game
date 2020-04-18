import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ErrorAlert extends StatelessWidget {
  final String message;
  final EdgeInsetsGeometry margin;

  const ErrorAlert({Key key, this.message = '', this.margin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var backgroundColor = Colors.red[700].withOpacity(0.7);

    return Visibility(
      visible: message != null,
      child: Container(
        margin: margin,
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: backgroundColor, borderRadius: BorderRadius.circular(5)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Errore:',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15),
              ),
              Text(
                message ?? '',
                style: TextStyle(color: Colors.white),
              )
            ],
          ),
        ),
      ),
    );
  }
}
