import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/logic/auth_controller.dart';

class _C {
  static const bg = Color(0xFFE6E6E6);
  static const primary = Color(0xFF7F95BC);
  static const accentPink = Color(0xFFB86A8C);
  static const accentGreen = Color(0xFF9ED3A5);
  static const onSurface = Color(0xFF333333);
  static const onSurfaceVar = Color(0xFF666666);
  static const btnColor = Color(0xFF715867);
}

class ResultsScreen extends StatefulWidget {
  final String result;
  final String playerName;
  final String opponentName;
  final String? playerPhotoUrl;
  final String? opponentPhotoUrl;

  const ResultsScreen({
    super.key,
    required this.result,
    required this.playerName,
    required this.opponentName,
    this.playerPhotoUrl,
    this.opponentPhotoUrl,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String get _emoji => widget.result == 'win'
      ? '\u{1F3C6}'
      : widget.result == 'lose'
      ? '\u{1F614}'
      : '\u{1F91D}';

  String get _title => widget.result == 'win'
      ? '\u00A1Victoria!'
      : widget.result == 'lose'
      ? 'Derrota'
      : 'Empate';

  Color get _color => widget.result == 'win'
      ? _C.accentGreen
      : widget.result == 'lose'
      ? _C.accentPink
      : _C.primary;

  Color get _colorBg => _color.withAlpha(40);

  String get _subtitle => widget.result == 'win'
      ? '\u00A1Felicidades, eres el ganador!'
      : widget.result == 'lose'
      ? 'Mejor suerte la pr\u00F3xima vez'
      : '\u00A1Buena partida para ambos!';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _colorBg,
                    boxShadow: [
                      BoxShadow(
                        color: _color.withAlpha(50),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(_emoji, style: const TextStyle(fontSize: 60)),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              FadeTransition(
                opacity: _fade,
                child: Column(
                  children: [
                    Text(
                      _title,
                      style: GoogleFonts.inter(
                        fontSize: 42,
                        color: _color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: _C.onSurfaceVar,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              FadeTransition(opacity: _fade, child: _summary()),
              const Spacer(flex: 2),
              _actions(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summary() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(180),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _C.primary.withAlpha(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Resumen de la Partida',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _C.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _playerCol(
                  widget.playerName,
                  widget.result == 'win',
                  _C.primary,
                  widget.playerPhotoUrl,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'VS',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    color: _C.onSurfaceVar.withAlpha(150),
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              Expanded(
                child: _playerCol(
                  widget.opponentName,
                  widget.result == 'lose',
                  _C.accentPink,
                  widget.opponentPhotoUrl,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _playerCol(
    String name,
    bool winner,
    Color defaultColor,
    String? photoUrl,
  ) {
    final ringColor = winner ? const Color(0xFFFFA726) : defaultColor;

    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: defaultColor.withAlpha(30),
            border: Border.all(color: ringColor, width: winner ? 3 : 2),
            boxShadow: winner
                ? [
                    BoxShadow(
                      color: const Color(0xFFFFA726).withAlpha(60),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
            image: photoUrl != null && photoUrl.isNotEmpty
                ? DecorationImage(
                    image: MemoryImage(base64Decode(photoUrl)),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: photoUrl == null || photoUrl.isEmpty
              ? Center(
                  child: Icon(
                    winner ? Icons.emoji_events_rounded : Icons.person,
                    color: ringColor,
                    size: 24,
                  ),
                )
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: _C.onSurface,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        if (winner)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              'Ganador',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFFFFA726),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }

  Widget _actions() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: _C.btnColor,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.replay_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Volver al Lobby',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: () async {
            await context.read<AuthController>().logout();
            if (mounted) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _C.btnColor.withAlpha(60)),
            ),
            child: Center(
              child: Text(
                'Cerrar Sesi\u00F3n',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _C.btnColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
