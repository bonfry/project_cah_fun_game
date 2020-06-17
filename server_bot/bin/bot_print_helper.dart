import 'package:colorize/colorize.dart';

void printBotMessage(String message,{int botId}){
  var colorizedMessage = Colorize('(Messaggio BOT $botId ) => $message')
    ..blue();

  print(colorizedMessage);
}

void printBotSuccessMessage(String message,{int botId}){
  var colorizedMessage = Colorize('(Successo BOT $botId) => $message')
    ..green();

  print(colorizedMessage);
}

void printBotSocketInput(String data,{int botId}){
  var colorizedMessage = Colorize('(Input da Server a BOT $botId) => $data')
    ..white()
    ..bgLightBlue();

  print(colorizedMessage);
}

void printBotSocketOutput(String data,{int botId}){
  var colorizedMessage = Colorize('(Output da BOT $botId) => $data')
    ..white()
    ..bgLightGreen();

  print(colorizedMessage);
}


void printBotError(String message,{int botId}){
  var colorizedMessage = Colorize('(Errore BOT $botId) => $message')
    ..red();

  print(colorizedMessage);
}