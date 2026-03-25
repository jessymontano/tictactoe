import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:tictactoe/logic/auth_controller.dart';

class MatchData {
  final String opponent;
  final String result;
  final String mode;
  final String date;
  final List<String> board;

  const MatchData({
    required this.opponent,
    required this.result,
    required this.mode,
    required this.date,
    required this.board,
  });
}

class HistoryController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<MatchData> _matches = [];
  bool _isLoading = true;

  List<MatchData> get matches => _matches;
  bool get isLoading => _isLoading;

  Future<void> fetchHistory(String currentUserId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final xQuery = await _firestore
          .collection('history')
          .where('x_player', isEqualTo: currentUserId)
          .get();

      final oQuery = await _firestore
          .collection('history')
          .where('o_player', isEqualTo: currentUserId)
          .get();

      final allDocs = [...xQuery.docs, ...oQuery.docs];

      allDocs.sort((a, b) {
        final aTime =
            (a.data()['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
        final bTime =
            (b.data()['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
        return bTime.compareTo(aTime);
      });

      List<MatchData> loadedMatches = [];

      for (var doc in allDocs) {
        final data = doc.data();

        final isX = data['x_player'] == currentUserId;
        final opponentId = isX ? data['o_player'] : data['x_player'];

        String opName = 'Desconocido';
        if (opponentId.toString().isNotEmpty) {
          final opDoc = await _firestore
              .collection('users')
              .doc(opponentId)
              .get();
          if (opDoc.exists) {
            opName = opDoc.data()?['username'] ?? 'Jugador';
          }
        }

        String result = 'draw';
        final winner = data['winner'];
        if (winner == 'x' && isX) result = 'win';
        if (winner == 'o' && !isX) result = 'win';
        if (winner == 'o' && isX) result = 'lose';
        if (winner == 'x' && !isX) result = 'lose';

        final dateObj =
            (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
        final dateStr = DateFormat("dd MMM, HH:mm").format(dateObj);

        loadedMatches.add(
          MatchData(
            opponent: opName,
            result: result,
            mode: data['gamemode'] ?? 'normal',
            date: dateStr,
            board: List<String>.from(data['final_board'] ?? []),
          ),
        );
      }

      _matches = loadedMatches;
    } catch (e) {
      // AA
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
