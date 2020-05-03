abstract class Card {
  final String id;
  final String text;

  Card(this.id, this.text);

  @override
  String toString() {
    return text.replaceAll('<\\n>', '\n');
  }

  Map<String, String> toJson() => {'id': id, 'text': text};
}

class WhiteCard extends Card {
  WhiteCard(String id, String text) : super(id, text);

  WhiteCard.fromJson(Map<String, dynamic> json)
      : this(json['id'] as String, json['text'] as String);
}

class BlackCard extends Card {
  int whiteCardsAllowed;

  BlackCard(String id, String text) : super(id, text) {
    whiteCardsAllowed = '<*>'.allMatches(text).length;
  }

  BlackCard.fromJson(Map<String, dynamic> json)
      : this(json['id'] as String, json['text'] as String);

  @override
  String toString() {
    return super.toString().replaceAll('<*>', '_____');
  }

  BlackCardCompiled compile(List<WhiteCard> whiteCards) {
    if (whiteCardsAllowed != whiteCards?.length) {
      throw Exception(
          'Different white cards from allowed ($whiteCardsAllowed != ${whiteCards?.length})');
    }

    var blackCardTextCompiled = text;

    for (var wc in whiteCards) {
      blackCardTextCompiled =
          blackCardTextCompiled.replaceFirst('<*>', wc.text);
    }

    return BlackCardCompiled(id, blackCardTextCompiled);
  }
}

class BlackCardCompiled extends Card {
  BlackCardCompiled(String id, String text) : super(id, text);
}
