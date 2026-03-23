class GameModel {
  final String id;
  final String xPlayer;
  final String oPlayer;
  final String state; // 'waiting', 'playing' o 'finished'
  final String gamemode;
  final String turn; // 'x' o 'o'
  final String winner; // 'x', 'o' o 'draw'
  List<String> board;
  List<int> xQueue;
  List<int> oQueue;

  GameModel({
    required this.id,
    required this.xPlayer,
    this.oPlayer = '',
    this.state = 'waiting',
    required this.gamemode,
    this.turn = 'x',
    this.winner = '',
    List<String>? board,
    List<int>? xQueue,
    List<int>? oQueue,
  }) : board = board ?? List.filled(0, ''),
       xQueue = xQueue ?? [],
       oQueue = oQueue ?? [];

  factory GameModel.fromMap(Map<String, dynamic> data, String documentId) {
    return GameModel(
      id: documentId,
      xPlayer: data['x_player'] ?? '',
      oPlayer: data['o_player'] ?? '',
      state: data['state'] ?? 'waiting',
      gamemode: data['gamemode'] ?? 'normal',
      turn: data['turn'] ?? 'x',
      winner: data['winner'] ?? '',
      board: List<String>.from(data['board'] ?? List.filled(9, '')),
      xQueue: List<int>.from(data['x_queue'] ?? []),
      oQueue: List<int>.from(data['o_queue'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'x_player': xPlayer,
      'o_player': oPlayer,
      'state': state,
      'gamemode': gamemode,
      'turn': turn,
      'winner': winner,
      'board': board,
      'x_queue': xQueue,
      'o_queue': oQueue,
    };
  }
}
