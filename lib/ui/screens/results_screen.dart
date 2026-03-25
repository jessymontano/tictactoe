import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/logic/auth_controller.dart';
import 'package:tictactoe/ui/theme/app_theme.dart';

class ResultsScreen extends StatefulWidget {
  final String result; // 'win', 'lose', 'draw'
  final String playerName;
  final String opponentName;

  const ResultsScreen({
    super.key,
    required this.result,
    required this.playerName,
    required this.opponentName,
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
        duration: const Duration(milliseconds: 800), vsync: this);
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
      ? AppColors.pGreen
      : widget.result == 'lose'
          ? AppColors.pCoral
          : AppColors.pTeal;

  Color get _colorBg => widget.result == 'win'
      ? AppColors.pGreenBg
      : widget.result == 'lose'
          ? AppColors.pPinkBg
          : AppColors.pTealBg;

  String get _subtitle => widget.result == 'win'
      ? '\u00A1Felicidades, eres el ganador!'
      : widget.result == 'lose'
          ? 'Mejor suerte la pr\u00F3xima vez'
          : '\u00A1Buena partida para ambos!';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.pGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(children: [
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
                      child:
                          Text(_emoji, style: const TextStyle(fontSize: 60))),
                ),
              ),
              const SizedBox(height: 28),
              FadeTransition(
                opacity: _fade,
                child: Column(children: [
                  Text(_title,
                      style: GoogleFonts.inter(
                          fontSize: 42,
                          color: _color,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(_subtitle,
                      style: GoogleFonts.inter(
                          fontSize: 15, color: AppColors.pTextMid),
                      textAlign: TextAlign.center),
                ]),
              ),
              const SizedBox(height: 40),
              FadeTransition(opacity: _fade, child: _summary()),
              const Spacer(flex: 2),
              _actions(),
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _summary() {
    return Container(
      decoration: AppTheme.pastelCard(),
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        Text('Resumen de la Partida',
            style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.pTextDark)),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(
              child: _playerCol(
                  widget.playerName, widget.result == 'win', AppColors.pCoral)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('VS',
                style: GoogleFonts.inter(
                    fontSize: 18,
                    color: AppColors.pTextLight,
                    fontWeight: FontWeight.w600)),
          ),
          Expanded(
              child: _playerCol(widget.opponentName, widget.result == 'lose',
                  AppColors.pTeal)),
        ]),
      ]),
    );
  }

  Widget _playerCol(String name, bool winner, Color color) {
    return Column(children: [
      Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withAlpha(30),
          border: winner
              ? Border.all(color: const Color(0xFFFFA726), width: 3)
              : null,
          boxShadow: winner
              ? [
                  BoxShadow(
                      color: const Color(0xFFFFA726).withAlpha(40),
                      blurRadius: 10,
                      offset: const Offset(0, 3))
                ]
              : [],
        ),
        child: Center(
            child: Icon(winner ? Icons.emoji_events_rounded : Icons.person,
                color: winner ? const Color(0xFFFFA726) : color, size: 24)),
      ),
      const SizedBox(height: 8),
      Text(name,
          style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.pTextDark,
              fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis),
      if (winner)
        Text('Ganador',
            style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFFFFA726),
                fontWeight: FontWeight.w600)),
    ]);
  }

  Widget _actions() {
    return Column(children: [
      GestureDetector(
        onTap: () =>
            Navigator.of(context).popUntil((route) => route.isFirst),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: AppTheme.pastelButton,
          child: Center(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.replay_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Text('Volver a Jugar',
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ],
          )),
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.pPurple.withAlpha(60)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
              child: Text('Cerrar Sesi\u00F3n',
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.pTextMid))),
        ),
      ),
    ]);
  }
}
