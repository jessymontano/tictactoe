import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tictactoe/ui/theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static final List<Map<String, dynamic>> _mock = [
    {'name': 'GatoMaster', 'wins': 45, 'games': 52},
    {'name': 'ProPlayer99', 'wins': 38, 'games': 48},
    {'name': 'UnisonChamp', 'wins': 35, 'games': 44},
    {'name': 'MathWizard', 'wins': 32, 'games': 40},
    {'name': 'TicTacPro', 'wins': 28, 'games': 38},
    {'name': 'SonoraGamer', 'wins': 25, 'games': 35},
    {'name': 'CatKing', 'wins': 22, 'games': 30},
    {'name': 'NeonPlayer', 'wins': 20, 'games': 29},
    {'name': 'StarGato', 'wins': 18, 'games': 26},
    {'name': 'PixelMaster', 'wins': 15, 'games': 24},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.pGradient),
        child: SafeArea(
          child: Column(children: [
            _appBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(children: [
                  const SizedBox(height: 16),
                  const Icon(Icons.emoji_events_rounded,
                      color: Color(0xFFFFA726), size: 52),
                  const SizedBox(height: 8),
                  Text('Top 10 Jugadores',
                      style: GoogleFonts.inter(
                          fontSize: 28,
                          color: AppColors.pPurpleDeep,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 24),
                  _podium(),
                  const SizedBox(height: 24),
                  _table(),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _appBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 44,
            height: 44,
            decoration: AppTheme.circleButton,
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.pPurpleDeep, size: 18),
          ),
        ),
        const Spacer(),
        Text('Clasificaci\u00F3n',
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.pTextDark)),
        const Spacer(),
        const SizedBox(width: 44),
      ]),
    );
  }

  Widget _podium() {
    if (_mock.length < 3) return const SizedBox();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _podiumPlace(_mock[1], 2, AppColors.pBlue, 90),
        const SizedBox(width: 10),
        _podiumPlace(_mock[0], 1, const Color(0xFFFFA726), 115),
        const SizedBox(width: 10),
        _podiumPlace(_mock[2], 3, AppColors.pPink, 75),
      ],
    );
  }

  Widget _podiumPlace(
      Map<String, dynamic> p, int rank, Color color, double h) {
    return Column(children: [
      Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withAlpha(30),
          border: Border.all(color: color, width: 3),
          boxShadow: [
            BoxShadow(
                color: color.withAlpha(40),
                blurRadius: 10,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Center(
            child: Text('$rank',
                style: GoogleFonts.inter(
                    fontSize: 22, color: color, fontWeight: FontWeight.bold))),
      ),
      const SizedBox(height: 6),
      Text(p['name'] as String,
          style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.pTextDark,
              fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis),
      Text('${p['wins']} victorias',
          style: GoogleFonts.inter(fontSize: 10, color: AppColors.pTextMid)),
      const SizedBox(height: 6),
      Container(
        width: 92,
        height: h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withAlpha(60), color.withAlpha(20)],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          border: Border.all(color: color.withAlpha(80)),
        ),
        child: Center(
            child: Text('#$rank',
                style: GoogleFonts.inter(
                    fontSize: 22,
                    color: color,
                    fontWeight: FontWeight.w700))),
      ),
    ]);
  }

  Widget _table() {
    return Container(
      decoration: AppTheme.pastelCard(),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(children: [
            _colHead('#', 30),
            Expanded(child: _colHead('Jugador', null)),
            _colHead('Victorias', 65),
            _colHead('Partidas', 60),
          ]),
        ),
        Divider(color: AppColors.pTextLight.withAlpha(60), height: 1),
        ...List.generate(_mock.length, (i) => _row(i + 1, _mock[i])),
      ]),
    );
  }

  Widget _colHead(String text, double? width) {
    final w = Text(text,
        style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.pTextMid,
            fontWeight: FontWeight.w600),
        textAlign: TextAlign.center);
    return width != null ? SizedBox(width: width, child: w) : w;
  }

  Widget _row(int rank, Map<String, dynamic> p) {
    Color rc;
    Color? rowBg;
    if (rank == 1) {
      rc = const Color(0xFFFFA726);
      rowBg = AppColors.pYellowBg;
    } else if (rank == 2) {
      rc = AppColors.pBlue;
      rowBg = AppColors.pBlueBg;
    } else if (rank == 3) {
      rc = AppColors.pPink;
      rowBg = AppColors.pPinkBg;
    } else {
      rc = AppColors.pTextMid;
      rowBg = null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: rowBg?.withAlpha(120),
        border: Border(
            bottom: BorderSide(
                color: AppColors.pTextLight.withAlpha(30), width: 0.5)),
      ),
      child: Row(children: [
        SizedBox(
            width: 30,
            child: Text('$rank',
                style: GoogleFonts.inter(
                    fontSize: 16, color: rc, fontWeight: FontWeight.bold))),
        Expanded(
            child: Text(p['name'] as String,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.pTextDark,
                    fontWeight: FontWeight.w500))),
        SizedBox(
            width: 65,
            child: Text('${p['wins']}',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.pPurpleDeep,
                    fontWeight: FontWeight.w700),
                textAlign: TextAlign.center)),
        SizedBox(
            width: 60,
            child: Text('${p['games']}',
                style: GoogleFonts.inter(
                    fontSize: 14, color: AppColors.pTextMid),
                textAlign: TextAlign.center)),
      ]),
    );
  }
}
