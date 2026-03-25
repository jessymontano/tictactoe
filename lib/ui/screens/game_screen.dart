import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/logic/auth_controller.dart';
import 'package:tictactoe/logic/game_controller.dart';
import 'package:tictactoe/ui/screens/results_screen.dart';
import 'package:tictactoe/ui/theme/app_theme.dart';

class GameScreen extends StatefulWidget {
  final String roomCode;
  final String gameMode;
  final File? playerPhoto;
  final String opponentName;

  const GameScreen({
    super.key,
    required this.roomCode,
    required this.gameMode,
    this.playerPhoto,
    this.opponentName = 'Oponente',
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final List<AnimationController> _cellAnims = [];
  final Set<int> _animatedCells = {};
  List<int>? _winLine;
  late AnimationController _winLineCtrl;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 9; i++) {
      _cellAnims.add(AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      ));
    }
    _winLineCtrl = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameController>().addListener(_onGameChanged);
    });
  }

  void _onGameChanged() {
    final game = context.read<GameController>().currentGame;
    if (game == null) return;

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
        if (_winLine != null) _winLineCtrl.forward();
      }
      Future.delayed(const Duration(milliseconds: 1500), _goToResults);
    }
  }

  List<int>? _findWinLine(List<String> board, String w) {
    const wins = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6],
    ];
    for (var p in wins) {
      if (p.every((i) => i < board.length && board[i] == w)) return p;
    }
    return null;
  }

  void _goToResults() {
    if (!mounted) return;
    final game = context.read<GameController>().currentGame!;
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

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => ResultsScreen(
        result: result,
        playerName: auth.currentUser?.username ?? 'Jugador 1',
        opponentName: widget.opponentName,
      ),
    ));
  }

  Future<void> _onCellTap(int index) async {
    final game = context.read<GameController>().currentGame;
    if (game == null) return;
    if (game.state != 'playing') return;

    final board = game.board;
    if (index >= board.length || board[index].isNotEmpty) return;

    final currentPlayer = game.turn == 'x' ? game.xPlayer : game.oPlayer;

    if (widget.gameMode == 'math') {
      final correct = await _showMathChallenge();
      if (!correct && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('\u00A1Respuesta incorrecta! Turno perdido.',
              style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: AppColors.pCoral,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
        return;
      }
    }

    await context.read<GameController>().makeMove(index, currentPlayer);
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
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.pPurpleDeep.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calculate_rounded,
                color: AppColors.pPurpleDeep, size: 24),
          ),
          const SizedBox(width: 10),
          Text('\u00A1Reto Matem\u00E1tico!',
              style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.pPurpleDeep)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: BoxDecoration(
              color: AppColors.pLavender,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text('$a $sym $b = ?',
                style: GoogleFonts.inter(
                    fontSize: 36,
                    color: AppColors.pTextDark,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            autofocus: true,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                color: AppColors.pTextDark,
                fontSize: 24,
                fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: '...',
              hintStyle: GoogleFonts.inter(
                  color: AppColors.pTextLight, fontSize: 24),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                      color: AppColors.pPurpleDeep, width: 2)),
            ),
          ),
          const SizedBox(height: 8),
          Text('\u00A1Solo tienes un intento!',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.pCoral,
                  fontWeight: FontWeight.w500)),
        ]),
        actions: [
          GestureDetector(
            onTap: () {
              final v = int.tryParse(ctrl.text.trim());
              Navigator.of(ctx).pop(v == answer);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: AppTheme.pastelButton,
              child: Center(
                child: Text('Responder',
                    style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  void dispose() {
    for (var c in _cellAnims) {
      c.dispose();
    }
    _winLineCtrl.dispose();
    try {
      context.read<GameController>().removeListener(_onGameChanged);
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthController>();
    final playerName = auth.currentUser?.username ?? 'Jugador 1';

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_cat.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(gradient: AppColors.pGradient),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha(140),
                    Colors.black.withAlpha(100),
                    Colors.black.withAlpha(160),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Consumer<GameController>(builder: (context, gameCtrl, _) {
              final game = gameCtrl.currentGame;

              if (game == null) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.white));
              }

              final userId = auth.currentUser?.uid ?? '';
              final isX = game.xPlayer == userId;
              final isXTurn = game.turn == 'x';
              final board = game.board.length >= 9
                  ? game.board
                  : List<String>.filled(9, '');

              return Column(children: [
                const SizedBox(height: 12),
                _header(game.id),
                const SizedBox(height: 16),
                _players(playerName, widget.opponentName, isX, isXTurn),
                const SizedBox(height: 14),
                _turnLabel(isXTurn, game.state, playerName),
                const Spacer(),
                _board(board),
                const Spacer(),
                if (widget.gameMode == 'math') _mathBadge(),
                const SizedBox(height: 24),
              ]);
            }),
          ),
        ],
      ),
    );
  }

  Widget _header(String code) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 44,
            height: 44,
            decoration: AppTheme.circleButton,
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.pPurpleDeep, size: 18),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(220),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_rounded,
                  color: AppColors.pPurpleDeep, size: 16),
              const SizedBox(width: 6),
              Text('En l\u00EDnea',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.pTextDark,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const Spacer(),
        const SizedBox(width: 44),
      ]),
    );
  }

  Widget _players(String p1Name, String p2Name, bool p1IsX, bool isXTurn) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(children: [
        Expanded(
            child: _playerCard(
                p1Name,
                p1IsX ? 'X' : 'O',
                p1IsX ? AppColors.pCoral : AppColors.pTeal,
                widget.playerPhoto,
                p1IsX == isXTurn)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('VS',
              style: GoogleFonts.inter(
                  fontSize: 20,
                  color: Colors.white.withAlpha(180),
                  fontWeight: FontWeight.w600)),
        ),
        Expanded(
            child: _playerCard(
                p2Name,
                p1IsX ? 'O' : 'X',
                p1IsX ? AppColors.pTeal : AppColors.pCoral,
                null,
                p1IsX != isXTurn)),
      ]),
    );
  }

  Widget _playerCard(
      String name, String symbol, Color color, File? photo, bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.white.withAlpha(180),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: active ? color : Colors.white.withAlpha(60), width: 2.5),
        boxShadow: active
            ? [
                BoxShadow(
                    color: color.withAlpha(50),
                    blurRadius: 14,
                    offset: const Offset(0, 4))
              ]
            : [
                BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
      ),
      child: Column(children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withAlpha(30),
            image: photo != null
                ? DecorationImage(image: FileImage(photo), fit: BoxFit.cover)
                : null,
          ),
          child: photo == null
              ? Center(
                  child: Text(symbol,
                      style: GoogleFonts.inter(
                          fontSize: 22,
                          color: color,
                          fontWeight: FontWeight.bold)))
              : null,
        ),
        const SizedBox(height: 6),
        Text(name,
            style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.pTextDark,
                fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis),
      ]),
    );
  }

  Widget _turnLabel(bool isXTurn, String state, String playerName) {
    final String text;
    final Color color;

    if (state == 'finished') {
      text = '\u00A1Partida terminada!';
      color = AppColors.pPurpleDeep;
    } else {
      text = 'Turno de ${isXTurn ? playerName : widget.opponentName}';
      color = isXTurn ? AppColors.pCoral : AppColors.pTeal;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey('$isXTurn-$state'),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(220),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _board(List<String> board) {
    final size = MediaQuery.of(context).size.width - 48;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(children: [
        CustomPaint(size: Size(size, size), painter: _GridPainter()),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3),
          itemCount: 9,
          itemBuilder: (_, i) => _cell(board, i),
        ),
        if (_winLine != null)
          AnimatedBuilder(
            animation: _winLineCtrl,
            builder: (_, __) => CustomPaint(
              size: Size(size, size),
              painter:
                  _WinPainter(cells: _winLine!, progress: _winLineCtrl.value),
            ),
          ),
      ]),
    );
  }

  Widget _cell(List<String> board, int index) {
    final value = index < board.length ? board[index] : '';
    return GestureDetector(
      onTap: () => _onCellTap(index),
      child: Container(
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(220),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: value.isNotEmpty
              ? ScaleTransition(
                  scale: CurvedAnimation(
                      parent: _cellAnims[index], curve: Curves.elasticOut),
                  child: _mark(value),
                )
              : null,
        ),
      ),
    );
  }

  Widget _mark(String player) {
    final isX = player == 'x';
    final color = isX ? AppColors.pCoral : AppColors.pTeal;
    final auth = context.read<AuthController>();
    final userId = auth.currentUser?.uid ?? '';
    final game = context.read<GameController>().currentGame;
    final isMine = (isX && game?.xPlayer == userId) ||
        (!isX && game?.oPlayer == userId);

    if (isMine && widget.playerPhoto != null) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 3),
          image: DecorationImage(
              image: FileImage(widget.playerPhoto!), fit: BoxFit.cover),
        ),
      );
    }

    return Text(
      player.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 48,
        color: color,
        fontWeight: FontWeight.bold,
        shadows: [Shadow(color: color.withAlpha(100), blurRadius: 14)],
      ),
    );
  }

  Widget _mathBadge() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(220),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.calculate_rounded,
              color: AppColors.pPurpleDeep, size: 18),
          const SizedBox(width: 6),
          Text('Modo Reto Matem\u00E1tico',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.pPurpleDeep,
                  fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(40)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final cw = size.width / 3;
    final ch = size.height / 3;

    canvas.drawLine(Offset(cw, 12), Offset(cw, size.height - 12), paint);
    canvas.drawLine(
        Offset(cw * 2, 12), Offset(cw * 2, size.height - 12), paint);
    canvas.drawLine(Offset(12, ch), Offset(size.width - 12, ch), paint);
    canvas.drawLine(
        Offset(12, ch * 2), Offset(size.width - 12, ch * 2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WinPainter extends CustomPainter {
  final List<int> cells;
  final double progress;
  _WinPainter({required this.cells, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (cells.length < 3) return;
    final cw = size.width / 3;
    final ch = size.height / 3;

    Offset center(int i) =>
        Offset((i % 3) * cw + cw / 2, (i ~/ 3) * ch + ch / 2);

    final start = center(cells.first);
    final end = center(cells.last);
    final current = Offset.lerp(start, end, progress)!;

    final glow = Paint()
      ..color = AppColors.pYellow.withAlpha(100)
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final line = Paint()
      ..color = AppColors.pYellow
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(start, current, glow);
    canvas.drawLine(start, current, line);
  }

  @override
  bool shouldRepaint(covariant _WinPainter old) => old.progress != progress;
}
