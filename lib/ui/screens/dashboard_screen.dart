import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/logic/game_controller.dart';

class _C {
  static const bg = Color(0xFFE6E6E6);
  static const primary = Color(0xFF7F95BC);
  static const accentPink = Color(0xFFB86A8C);
  static const accentGreen = Color(0xFF9ED3A5);
  static const tertiary = Color(0xFF9B7BB5);
  static const onSurface = Color(0xFF333333);
  static const onSurfaceVar = Color(0xFF666666);
  static const btnColor = Color(0xFF715867);
  static const gold = Color(0xFFFFA726);
  static const silver = Color(0xFF90A4AE);
  static const bronze = Color(0xFFCD7F32);
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> _mock = [];

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: _C.bg),
          Positioned.fill(child: CustomPaint(painter: _BgPainter())),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        _buildTrophy(),
                        const SizedBox(height: 20),
                        _buildPodium(),
                        const SizedBox(height: 20),
                        _buildTable(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadLeaderboard() async {
    final data = await context.read<GameController>().getLeaderboard();

    List<Map<String, dynamic>> temp = data.map((p) {
      final wins = p['wins'];
      final losses = p['losses'];

      return {'name': p['name'], 'wins': wins, 'games': wins + losses};
    }).toList();

    setState(() {
      _mock = temp.take(10).toList(); //top ten
    });
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: _C.onSurface,
                size: 28,
              ),
            ),
          ),
          const Spacer(),
          Text(
            'Clasificaci\u00F3n',
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

  Widget _buildTrophy() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _C.gold.withAlpha(30),
            border: Border.all(color: _C.gold.withAlpha(80), width: 2),
          ),
          child: const Icon(
            Icons.emoji_events_rounded,
            color: _C.gold,
            size: 38,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Top 10 Jugadores',
          style: GoogleFonts.inter(
            fontSize: 24,
            color: _C.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Los mejores de la temporada',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: _C.onSurfaceVar,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPodium() {
    if (_mock.length < 3) return const SizedBox();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _podiumPlace(_mock[1], 2, _C.silver, 80),
        const SizedBox(width: 8),
        _podiumPlace(_mock[0], 1, _C.gold, 100),
        const SizedBox(width: 8),
        _podiumPlace(_mock[2], 3, _C.bronze, 65),
      ],
    );
  }

  Widget _podiumPlace(Map<String, dynamic> p, int rank, Color color, double h) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: color, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(40),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.person_rounded,
              color: Colors.grey.shade300,
              size: 26,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          p['name'] as String,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: _C.onSurface,
            fontWeight: FontWeight.w700,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${p['wins']} victorias',
          style: GoogleFonts.inter(
            fontSize: 9,
            color: _C.onSurfaceVar,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 88,
          height: h,
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border.all(color: color.withAlpha(60)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (rank == 1)
                Icon(Icons.emoji_events_rounded, color: color, size: 22),
              Text(
                '#$rank',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(180),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            color: Colors.white.withAlpha(100),
            child: Row(
              children: [
                SizedBox(
                  width: 30,
                  child: Text(
                    '#',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: _C.onSurfaceVar,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Jugador',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: _C.onSurfaceVar,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    'Wins',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: _C.onSurfaceVar,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: 55,
                  child: Text(
                    'Total',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: _C.onSurfaceVar,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: _C.onSurfaceVar.withAlpha(25), height: 1),
          ...List.generate(_mock.length, (i) => _row(i + 1, _mock[i])),
        ],
      ),
    );
  }

  Widget _row(int rank, Map<String, dynamic> p) {
    Color rc;
    Color? rowBg;
    if (rank == 1) {
      rc = _C.gold;
      rowBg = _C.gold.withAlpha(18);
    } else if (rank == 2) {
      rc = _C.silver;
      rowBg = _C.silver.withAlpha(15);
    } else if (rank == 3) {
      rc = _C.bronze;
      rowBg = _C.bronze.withAlpha(15);
    } else {
      rc = _C.onSurfaceVar;
      rowBg = null;
    }

    final pct = (p['games'] as int) > 0
        ? ((p['wins'] as int) / (p['games'] as int) * 100).round()
        : 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: rowBg,
        border: Border(
          bottom: BorderSide(color: _C.onSurfaceVar.withAlpha(15), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: rank <= 3
                ? Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: rc.withAlpha(30),
                    ),
                    child: Center(
                      child: Text(
                        '$rank',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: rc,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                : Text(
                    '$rank',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: _C.onSurfaceVar,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _C.primary.withAlpha(25),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: _C.primary.withAlpha(120),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p['name'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: _C.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '$pct% win rate',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: _C.onSurfaceVar,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              '${p['wins']}',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: _C.btnColor,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 55,
            child: Text(
              '${p['games']}',
              style: GoogleFonts.inter(fontSize: 14, color: _C.onSurfaceVar),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _BgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(77);
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
