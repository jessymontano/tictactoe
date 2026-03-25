import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/logic/auth_controller.dart';
import 'package:tictactoe/logic/history_controller.dart';

class _C {
  static const bg = Color(0xFFE6E6E6);
  static const primary = Color(0xFF7F95BC);
  static const accentPink = Color(0xFFB86A8C);
  static const accentGreen = Color(0xFF9ED3A5);
  static const onSurface = Color(0xFF333333);
  static const onSurfaceVar = Color(0xFF666666);
  static const btnColor = Color(0xFF715867);
}

class _MatchData {
  final String opponent;
  final String result;
  final String mode;
  final String date;
  final List<String> board;

  const _MatchData({
    required this.opponent,
    required this.result,
    required this.mode,
    required this.date,
    required this.board,
  });
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthController>();
      final userId = auth.currentUser?.uid ?? '';
      context.read<HistoryController>().fetchHistory(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: _C.bg),
          Positioned.fill(child: CustomPaint(painter: _BgPainter())),
          SafeArea(
            child: Consumer<HistoryController>(
              builder: (context, historyCtrl, _) {
                if (historyCtrl.isLoading) {
                  return Column(
                    children: [
                      _buildHeader(context),
                      const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  );
                }
                final matches = historyCtrl.matches;

                return Column(
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 8),
                    _buildStats(matches),
                    const SizedBox(height: 16),
                    Expanded(child: _buildMatchList(matches)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.arrow_back_rounded,
                color: _C.onSurface,
                size: 28,
              ),
            ),
          ),
          const Spacer(),
          Text(
            'Historial',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _C.onSurface,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildStats(List<MatchData> matches) {
    final wins = matches.where((m) => m.result == 'win').length;
    final losses = matches.where((m) => m.result == 'lose').length;
    final draws = matches.where((m) => m.result == 'draw').length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _statCard(
              '$wins',
              'Victorias',
              _C.accentGreen,
              Icons.check_circle_rounded,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _statCard(
              '$losses',
              'Derrotas',
              _C.accentPink,
              Icons.cancel_rounded,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _statCard(
              '$draws',
              'Empates',
              _C.primary,
              Icons.remove_circle_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(150),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _C.onSurfaceVar,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchList(List<MatchData> matches) {
    if (matches.isEmpty) {
      return Center(
        child: Text(
          "Aún no has jugado ninguna partida.",
          style: GoogleFonts.inter(
            color: _C.onSurfaceVar,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: matches.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _matchCard(matches[i]),
    );
  }

  Widget _matchCard(MatchData match) {
    Color resultColor;
    String resultLabel;
    IconData resultIcon;
    switch (match.result) {
      case 'win':
        resultColor = _C.accentGreen;
        resultLabel = 'Victoria';
        resultIcon = Icons.emoji_events_rounded;
      case 'lose':
        resultColor = _C.accentPink;
        resultLabel = 'Derrota';
        resultIcon = Icons.sentiment_dissatisfied_rounded;
      default:
        resultColor = _C.primary;
        resultLabel = 'Empate';
        resultIcon = Icons.handshake_rounded;
    }

    String modeLabel;
    IconData modeIcon;
    switch (match.mode) {
      case 'math':
        modeLabel = 'Matem\u00E1tico';
        modeIcon = Icons.calculate_rounded;
      case 'infinite':
        modeLabel = 'Sin Fin';
        modeIcon = Icons.all_inclusive_rounded;
      default:
        modeLabel = 'Normal';
        modeIcon = Icons.sports_esports_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(180),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: resultColor.withAlpha(40)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: resultColor.withAlpha(25),
            ),
            child: Icon(resultIcon, color: resultColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'vs ${match.opponent}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _C.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: resultColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        resultLabel,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: resultColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(modeIcon, size: 12, color: _C.onSurfaceVar),
                    const SizedBox(width: 4),
                    Text(
                      modeLabel,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: _C.onSurfaceVar,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.schedule_rounded,
                      size: 12,
                      color: _C.onSurfaceVar,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      match.date,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: _C.onSurfaceVar,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _miniBoard(match.board),
        ],
      ),
    );
  }

  Widget _miniBoard(List<String> board) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _C.bg.withAlpha(180),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(3),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: 9,
        itemBuilder: (_, i) {
          final v = i < board.length ? board[i] : '';
          Color cellColor;
          if (v == 'x') {
            cellColor = _C.primary;
          } else if (v == 'o') {
            cellColor = _C.accentPink;
          } else {
            cellColor = Colors.transparent;
          }
          return Container(
            decoration: BoxDecoration(
              color: v.isNotEmpty
                  ? cellColor.withAlpha(40)
                  : Colors.white.withAlpha(120),
              borderRadius: BorderRadius.circular(2),
            ),
            child: v.isNotEmpty
                ? Center(
                    child: Text(
                      v.toUpperCase(),
                      style: TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.w800,
                        color: cellColor,
                      ),
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }
}

class _BgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(55);
    final symbols = ['X', 'O', '#'];
    final colors = [
      _C.primary.withAlpha(22),
      _C.accentPink.withAlpha(22),
      _C.accentGreen.withAlpha(25),
      _C.onSurfaceVar.withAlpha(12),
    ];

    for (int i = 0; i < 30; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final symbol = symbols[rng.nextInt(symbols.length)];
      final color = colors[rng.nextInt(colors.length)];
      final fontSize = 16.0 + rng.nextDouble() * 26;
      final angle = (rng.nextDouble() - 0.5) * 0.6;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);

      final tp = TextPainter(
        text: TextSpan(
          text: symbol,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
