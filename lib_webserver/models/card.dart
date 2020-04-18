
abstract class Card{
  final String id;
  final String text;

  Card(this.id,this.text);

  @override
  String toString(){
    return text.replaceAll('<\\n>', '\n');
  }

  Map<String,String> toMap(){
    return {
      'id': id,
      'text': text
    };
  }
}

class WhiteCard extends Card{
  WhiteCard(String id,String text):super(id,text);
}

class BlackCard extends Card{

  int whiteCardsAllowed;
  
  BlackCard(String id,String text):super(id,text){
    whiteCardsAllowed = text.allMatches('<*>').length;
  }

  @override
  String toString() {
    return super.toString().replaceAll('<*>', '_____');
  }

  BlackCardCompiled compile(List<WhiteCard> whiteCards){
    if(whiteCardsAllowed != whiteCards?.length){
      throw Exception('Different white cards from allowed ($whiteCardsAllowed != ${whiteCards?.length})');
    }

    var blackCardTextCompiled = text;

    for(var wc in whiteCards){
      blackCardTextCompiled = blackCardTextCompiled.replaceFirst('<*>', wc.text);
    }

    return BlackCardCompiled(id,blackCardTextCompiled);
  }
}

class BlackCardCompiled extends Card{
  BlackCardCompiled(String id,String text):super(id,text);
}