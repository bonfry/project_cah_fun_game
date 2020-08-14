import 'package:flutter/material.dart';

/// Transparent app bar used by Lobby and Game page
class TransparentAppBar extends AppBar {
  TransparentAppBar({
    Widget title,
    Widget leading,
    List<Widget> actions,
  }) : super(
            title: title,
            leading: null,
            actions: actions,
            elevation: 0,
            backgroundColor: Colors.transparent,
            actionsIconTheme: IconThemeData(color: Colors.black),
            automaticallyImplyLeading:false
            );
}