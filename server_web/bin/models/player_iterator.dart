import 'dart:math';

class PlayersIterator {
  LinkedNode<String> _currentPlayerNode;
  LinkedCircularList<String> _listToIterate;

  PlayersIterator(Iterable<String> players) {
    _listToIterate = LinkedCircularList<String>(players);
  }

  bool moveNext() {
    if (_currentPlayerNode != null && _currentPlayerNode.hasNext) {
      _currentPlayerNode = _currentPlayerNode.getNext();
      return true;
    } else {
      return false;
    }
  }

  bool moveNextRandom() {
    var randomGenerator = Random();

    if (length == 1) {
      _currentPlayerNode = _listToIterate.head;
      return true;
    }

    var playerIndex = randomGenerator.nextInt(_listToIterate.length - 1);
    _currentPlayerNode = _listToIterate._getNode(playerIndex);

    return _currentPlayerNode != null;
  }

  void addPlayer(String player) =>
      _listToIterate.addItem(LinkedNode<String>(player));

  String removePlayer(String player) => _listToIterate.removePlayer(player);

  int get length {
    return _listToIterate.length;
  }

  String get currentPlayer {
    return _currentPlayerNode.value;
  }
}

class LinkedCircularList<T> {
  LinkedNode<T> head;
  LinkedNode<T> tail;
  int length;

  LinkedCircularList(Iterable<T> players) : length = 0 {
    for (var player in players) {
      addItem(LinkedNode<T>(player));
    }
  }

  T currentPlayer;

  T removePlayer(T player) {
    T itemRemoved;

    if (length == 0) {
      throw Exception('No player exists');
    } else if (length == 1 && head.value == player) {
      itemRemoved = head.value;

      head = null;
      tail = null;

      return itemRemoved;
    }

    LinkedNode<T> prevNode;
    var currentNode = head;

    while (currentNode.hasNext) {
      prevNode = currentNode;
      currentNode = currentNode.getNext();

      if (currentNode.value == player) {
        if (currentNode == tail) {
          tail = prevNode;
        }

        itemRemoved = currentNode.value;
        prevNode.next = currentNode.getNext();
        length--;

        return itemRemoved;
      }
    }

    throw Exception('Player not found');
  }

  LinkedNode<T> _getNode(int index) {
    var node = head;

    for (var i = 1; i < index; i++) {
      node = node.getNext();
    }

    return node;
  }

  T getItem(int index) {
    var nodeFound = _getNode(index);
    return nodeFound?.value;
  }

  void addItem(LinkedNode<T> item) {
    if (head == null) {
      head = item;
    } else {
      tail._next = item;
    }

    tail = item;
    item._next = head;
    length++;
  }
}

class LinkedNode<T> {
  T value;
  LinkedNode _next;

  LinkedNode(this.value, {LinkedNode<T> next}) : _next = next;

  set next(LinkedNode<T> nextNode) {
    _next = nextNode;
  }

  LinkedNode<T> getNext() {
    return _next;
  }

  bool get hasNext {
    return _next != null;
  }
}
