import 'package:flutter/material.dart';

class AppbarAction {
  final IconData buttonIcon;
  final String buttonText;
  final Function onTap;
  final bool visible;
  AppbarAction(
      {@required this.buttonIcon,
      @required this.buttonText,
      @required this.onTap,
      this.visible = true});

  Widget toIconButtton() {
    return Visibility(
        visible: visible,
        child: IconButton(
          icon: Icon(buttonIcon),
          tooltip: buttonText,
          onPressed: onTap,
        ));
  }

  Widget toDrawerButton() {
    return Visibility(
      visible: visible,
      child: ListTile(
        leading: Icon(buttonIcon),
        title: Text(buttonText),
        onTap: onTap,
      ),
    );
  }
}

extension AppbarActions on List<AppbarAction>{
  List<Widget> toIconButtonList() => 
    this.map((appbarAction) => appbarAction.toIconButtton()).toList();
  
   List<Widget> toDraweButtonList() => 
    this.map((appbarAction) => appbarAction.toDrawerButton()).toList();
}