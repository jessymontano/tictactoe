import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/logic/auth_controller.dart';
import 'package:tictactoe/logic/game_controller.dart';
import 'package:tictactoe/ui/screens/results_screen.dart';

class _GC {
  static const bg = Color(0xFFE6E6E6);
  static const primary = Color(0xFF7F95BC);
  static const accentPink = Color(0xFFB86A8C);
  static const accentGreen = Color(0xFF9ED3A5);
  static const onSurface = Color(0xFF333333);
  static const onSurfaceVar = Color(0xFF666666);
  static const btnColor = Color(0xFF715867);
}

class GameScreen extends StatefulWidget {
  final String roomCode;
  final String gameMode;

  const GameScreen({super.key, required this.roomCode, required this.gameMode});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final List<AnimationController> _cellAnims = [];
  final Set<int> _animatedCells = {};
  List<int>? _winLine;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 9; i++) {
      _cellAnims.add(
        AnimationController(
          duration: const Duration(milliseconds: 400),
          vsync: this,
        ),
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameController>().addListener(_onGameChanged);
    });
  }

  void _onGameChanged() {
    if (!mounted) return;
    final game = context.read<GameController>().currentGame;

    if (game == null) {
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      return;
    }

    final board = game.board;
    for (int i = 0; i < min(9, board.length); i++) {
      if (board[i].isNotEmpty && !_animatedCells.contains(i)) {
        _animatedCells.add(i);
        _cellAnims[i].forward();
      }
    }

    if (game.state == 'finished' && !_navigated) {
      _navigated = true;
      if (game.winner != 'draw') {
        _winLine = _findWinLine(board, game.winner);
      }

      if (!mounted) return;
      setState(() {});

      setState(() {});
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        _goToResults();
      });
    }
  }

  List<int>? _findWinLine(List<String> board, String w) {
    const wins = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    for (var p in wins) {
      if (p.every((i) => i < board.length && board[i] == w)) return p;
    }
    return null;
  }

  void _goToResults() {
    if (!mounted) return;

    final gameCtrl = context.read<GameController>();
    final game = gameCtrl.currentGame!;
    final auth = context.read<AuthController>();
    final userId = auth.currentUser?.uid ?? '';
    final isX = game.xPlayer == userId;

    String result;
    if (game.winner == 'draw') {
      result = 'draw';
    } else if ((game.winner == 'x' && isX) || (game.winner == 'o' && !isX)) {
      result = 'win';
    } else {
      result = 'lose';
    }

    final opponentName = isX ? gameCtrl.oPlayerName : gameCtrl.xPlayerName;
    final myPfp = isX ? gameCtrl.xPlayerPfpUrl : gameCtrl.oPlayerPfpUrl;
    final opponentPfp = isX ? gameCtrl.oPlayerPfpUrl : gameCtrl.xPlayerPfpUrl;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultsScreen(
          result: result,
          playerName: auth.currentUser?.username ?? 'Jugador 1',
          opponentName: opponentName,
          playerPhotoUrl: myPfp,
          opponentPhotoUrl: opponentPfp, //TODO: agregar nombre oponente
        ),
      ),
    );
  }

  Future<void> _onCellTap(int index) async {
    final game = context.read<GameController>().currentGame;
    if (game == null || game.state != 'playing') return;

    final board = game.board;
    if (index >= board.length || board[index].isNotEmpty) return;

    final auth = context.read<AuthController>();
    final userId = auth.currentUser?.uid ?? '';

    if (userId != game.xPlayer && userId != game.oPlayer) return;

    final isMyTurn =
        (game.turn == 'x' && game.xPlayer == userId) ||
        (game.turn == 'o' && game.oPlayer == userId);

    if (!isMyTurn) return;

    if (widget.gameMode == 'math') {
      final correct = await _showMathChallenge();
      if (!correct && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '\u00A1Respuesta incorrecta! Turno perdido.',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: _GC.accentPink,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        await context.read<GameController>().passTurn();
        return;
      }
    }

    await context.read<GameController>().makeMove(index, userId);
  }

  Future<bool> _showMathChallenge() async {
    final rng = Random();
    int a, b, answer;
    String sym;
    switch (rng.nextInt(3)) {
      case 0:
        a = rng.nextInt(50) + 1;
        b = rng.nextInt(50) + 1;
        sym = '+';
        answer = a + b;
      case 1:
        a = rng.nextInt(50) + 10;
        b = rng.nextInt(a) + 1;
        sym = '-';
        answer = a - b;
      default:
        a = rng.nextInt(12) + 2;
        b = rng.nextInt(12) + 2;
        sym = '\u00D7';
        answer = a * b;
    }

    final ctrl = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _GC.btnColor.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.calculate_rounded,
                color: _GC.btnColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '\u00A1Reto Matem\u00E1tico!',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _GC.onSurface,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                color: _GC.bg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$a $sym $b = ?',
                style: GoogleFonts.inter(
                  fontSize: 36,
                  color: _GC.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: _GC.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: '...',
                hintStyle: GoogleFonts.inter(
                  color: _GC.onSurfaceVar,
                  fontSize: 24,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _GC.btnColor, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '\u00A1Solo tienes un intento!',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: _GC.accentPink,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {
              final v = int.tryParse(ctrl.text.trim());
              Navigator.of(ctx).pop(v == answer);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _GC.btnColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  'Responder',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _restart() {
    final game = context.read<GameController>().currentGame;
    if (game == null) return;
    setState(() {
      _navigated = false;
      _winLine = null;
      _animatedCells.clear();
      for (var c in _cellAnims) {
        c.reset();
      }
    });
    context.read<GameController>().startGame();
  }

  @override
  void dispose() {
    for (var c in _cellAnims) {
      c.dispose();
    }
    try {
      context.read<GameController>().removeListener(_onGameChanged);
    } catch (_) {}
    super.dispose();
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthController>();

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        await _showExitDialog();
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(color: _GC.bg),
            Positioned.fill(child: CustomPaint(painter: _GameBgPainter())),
            SafeArea(
              child: Consumer<GameController>(
                builder: (context, gameCtrl, _) {
                  final game = gameCtrl.currentGame;
                  if (game == null) {
                    return const Center(
                      child: CircularProgressIndicator(color: _GC.primary),
                    );
                  }

                  final userId = auth.currentUser?.uid ?? '';
                  final isX = game.xPlayer == userId;
                  final isXTurn = game.turn == 'x';
                  final board = game.board.length >= 9
                      ? game.board
                      : List<String>.filled(9, '');

                  final xPhoto = gameCtrl.xPlayerPfpUrl;
                  final oPhoto = gameCtrl.oPlayerPfpUrl;
                  final xName = gameCtrl.xPlayerName;
                  final oName = gameCtrl.oPlayerName;

                  final p1Photo = isX ? xPhoto : oPhoto;
                  final p2Photo = isX ? oPhoto : xPhoto;
                  final p1Name = isX ? xName : oName;
                  final p2Name = isX ? oName : xName;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 6),
                        _buildPlayers(
                          p1Name,
                          p2Name,
                          isX,
                          isXTurn,
                          p1Photo,
                          p2Photo,
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: Center(
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: _buildBoard(board),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildModeBadge(),
                        const SizedBox(height: 10),
                        _buildRestartButton(),
                        const SizedBox(height: 14),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: _showExitDialog,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: _GC.onSurface,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayers(
    String p1Name,
    String p2Name,
    bool p1IsX,
    bool isXTurn,
    String? p1Photo,
    String? p2Photo,
  ) {
    return Row(
      children: [
        Expanded(
          child: _playerCard(
            p1Name,
            p1IsX ? 'X' : 'O',
            p1IsX ? _GC.primary : _GC.accentPink,
            p1Photo,
            p1IsX == isXTurn,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withAlpha(153),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'VS',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: _GC.onSurfaceVar,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: _playerCard(
            p2Name,
            p1IsX ? 'O' : 'X',
            p1IsX ? _GC.accentPink : _GC.primary,
            p2Photo,
            p1IsX != isXTurn,
          ),
        ),
      ],
    );
  }

  Widget _playerCard(
    String name,
    String symbol,
    Color color,
    String? photoUrl,
    bool active,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: active
            ? Colors.white.withAlpha(120)
            : Colors.white.withAlpha(60),
        borderRadius: BorderRadius.circular(24),
        border: active
            ? Border.all(color: color.withAlpha(80), width: 1.5)
            : null,
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: color, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  image: photoUrl != null
                      ? DecorationImage(
                          image: MemoryImage(base64Decode(photoUrl)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: photoUrl == null
                    ? Icon(
                        Icons.person_rounded,
                        color: Colors.grey.shade300,
                        size: 30,
                      )
                    : null,
              ),
              Positioned(
                bottom: -3,
                right: -3,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    symbol,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: _GC.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBoard(List<String> board) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(153),
        borderRadius: BorderRadius.circular(40),
      ),
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 9,
        itemBuilder: (_, i) => _cell(board, i),
      ),
    );
  }

  Widget _cell(List<String> board, int index) {
    final value = index < board.length ? board[index] : '';
    final isWin = _winLine?.contains(index) ?? false;

    return GestureDetector(
      onTap: () => _onCellTap(index),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isWin ? _GC.accentGreen.withAlpha(50) : Colors.white,
          border: isWin ? Border.all(color: _GC.accentGreen, width: 2.5) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: value.isNotEmpty
              ? ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _cellAnims[index],
                    curve: Curves.elasticOut,
                  ),
                  child: _mark(value),
                )
              : null,
        ),
      ),
    );
  }

  Widget _mark(String player) {
    final isX = player == 'x';
    final color = isX ? _GC.primary : _GC.accentPink;
    final gameCtrl = context.read<GameController>();
    final photoUrl = isX ? gameCtrl.xPlayerPfpUrl : gameCtrl.oPlayerPfpUrl;

    if (photoUrl != null) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2.5),
          image: DecorationImage(
            image: MemoryImage(base64Decode(photoUrl)),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Text(
      player.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 36,
        color: color,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Future<void> _showExitDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(24),
        ),
        title: Text(
          '¿Salir de la partida?',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: _GC.onSurface,
          ),
        ),
        content: Text(
          'La sala se cerrará para ambos jugadores.',
          style: GoogleFonts.inter(color: _GC.onSurfaceVar),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Salir',
              style: GoogleFonts.inter(
                color: _GC.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<GameController>().exitAndCleanRoom();
      if (mounted) Navigator.of(context).pop();
    }
  }

  Widget _buildModeBadge() {
    String label;
    IconData icon;
    switch (widget.gameMode) {
      case 'math':
        label = 'Modo Matem\u00E1tico';
        icon = Icons.calculate_rounded;
      case 'infinite':
        label = 'Modo Sin Fin';
        icon = Icons.all_inclusive_rounded;
      default:
        label = 'Modo Normal';
        icon = Icons.sports_esports_rounded;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(150),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _GC.onSurfaceVar, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _GC.onSurfaceVar,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestartButton() {
    return GestureDetector(
      onTap: _restart,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: _GC.btnColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Reiniciar Partida',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _GameBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(99);
    final symbols = ['X', 'O', '#'];
    final colors = [
      _GC.primary.withAlpha(22),
      _GC.accentPink.withAlpha(22),
      _GC.accentGreen.withAlpha(25),
      _GC.onSurfaceVar.withAlpha(12),
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
