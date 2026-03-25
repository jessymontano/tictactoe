import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:tictactoe/data/models/game_model.dart';

class GameController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  GameModel? _currentGame;
  StreamSubscription<DocumentSnapshot>? _gameSubscription;

  GameModel? get currentGame => _currentGame;

  void startLocalGame(
      String roomCode, String xPlayer, String oPlayer, String gameMode) {
    _gameSubscription?.cancel();
    _currentGame = GameModel(
      id: roomCode,
      xPlayer: xPlayer,
      oPlayer: oPlayer,
      state: 'playing',
      gamemode: gameMode,
      board: List.filled(9, ''),
    );
    notifyListeners();
  }

  Future<void> createRoom(
    String roomCode,
    String userId,
    String gamemode,
  ) async {
    final newRoom = GameModel(
      id: roomCode,
      xPlayer: userId,
      gamemode: gamemode,
    );

    await _firestore.collection('games').doc(roomCode).set({
      'x_player': newRoom.xPlayer,
      'o_player': '',
      'state': newRoom.state,
      'gamemode': newRoom.gamemode,
      'turn': newRoom.turn,
      'board': newRoom.board,
      'winner': newRoom.winner,
      'x_queue': newRoom.xQueue,
      'o_queue': newRoom.oQueue,
    });

    _listenRoom(roomCode);
  }

  Future<bool> joinRoom(String roomCode, String userId) async {
    final docRef = _firestore.collection('games').doc(roomCode);
    final docSnap = await docRef.get();

    if (docSnap.exists && docSnap.data()!['state'] == 'waiting') {
      await docRef.update({'o_player': userId, 'state': 'playing'});
      _listenRoom(roomCode);
      return true;
    }
    return false;
  }

  void _listenRoom(String roomCode) {
    _gameSubscription?.cancel();

    _gameSubscription = _firestore
        .collection('games')
        .doc(roomCode)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            final data = snapshot.data()!;

            _currentGame = GameModel(
              id: roomCode,
              xPlayer: data['x_player'],
              oPlayer: data['o_player'],
              state: data['state'],
              gamemode: data['gamemode'],
              turn: data['turn'],
              winner: data['winner'],
              board: List<String>.from(data['board']),
              xQueue: List<int>.from(data['x_queue']),
              oQueue: List<int>.from(data['o_queue']),
            );

            notifyListeners();
          } else {
            _currentGame = null;
            notifyListeners();
          }
        });
  }

  Future<void> makeMove(int index, String userId) async {
    if (_currentGame == null || _currentGame!.state != 'playing') return;

    String shape = _currentGame!.xPlayer == userId ? 'x' : 'o';

    if (_currentGame!.turn != shape) return;
    if (_currentGame!.board[index] != '') return;

    _currentGame!.registerMove(index, shape);

    String newState = 'playing';
    String winner = '';

    if (_win(_currentGame!.board, shape)) {
      newState = 'finished';
      winner = shape;
    } else if (!_currentGame!.board.contains('')) {
      newState = 'finished';
      winner = 'draw';
    }

    String nextTurn = shape == 'x' ? 'o' : 'x';

    if (_gameSubscription == null) {
      _currentGame = GameModel(
        id: _currentGame!.id,
        xPlayer: _currentGame!.xPlayer,
        oPlayer: _currentGame!.oPlayer,
        state: newState,
        gamemode: _currentGame!.gamemode,
        turn: nextTurn,
        winner: winner,
        board: List<String>.from(_currentGame!.board),
        xQueue: List<int>.from(_currentGame!.xQueue),
        oQueue: List<int>.from(_currentGame!.oQueue),
      );
      notifyListeners();
      return;
    }

    await _firestore.collection('games').doc(_currentGame!.id).update({
      'board': _currentGame!.board,
      'state': newState,
      'winner': winner,
      'x_queue': _currentGame!.xQueue,
      'o_queue': _currentGame!.oQueue,
      'turn': nextTurn,
    });

    if (newState == 'finished') {
      await _firestore.collection('history').add({
        'room_id': _currentGame!.id,
        'x_player': _currentGame!.xPlayer,
        'o_player': _currentGame!.oPlayer,
        'gamemode': _currentGame!.gamemode,
        'winner': winner,
        'final_board': _currentGame!.board,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> exitAndCleanRoom() async {
    if (_currentGame == null) return;

    String roomId = _currentGame!.id;

    _gameSubscription?.cancel();
    await _firestore.collection('games').doc(roomId).delete();

    _currentGame = null;
    notifyListeners();
  }

  bool _win(List<String> board, String shape) {
    const winPositions = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var position in winPositions) {
      if (board[position[0]] == shape &&
          board[position[1]] == shape &&
          board[position[2]] == shape) {
        return true;
      }
    }
    return false;
  }

  @override
  void dispose() {
    _gameSubscription?.cancel();
    super.dispose();
  }
}
