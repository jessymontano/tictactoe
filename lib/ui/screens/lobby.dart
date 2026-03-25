import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/core/utils.dart';
import 'package:tictactoe/logic/auth_controller.dart';
import 'package:tictactoe/logic/game_controller.dart';
import 'package:tictactoe/ui/screens/dashboard_screen.dart';
import 'package:tictactoe/ui/screens/game_screen.dart';
import 'package:tictactoe/ui/screens/history_screen.dart';

class _C {
  static const primary = Color(0xFF775062);
  static const primaryContainer = Color(0xFFFCC9DF);
  static const secondary = Color(0xFF32626F);
  static const secondaryContainer = Color(0xFFDFF7FF);
  static const tertiary = Color(0xFF3E634E);
  static const tertiaryContainer = Color(0xFFD3FEE2);
  static const onBg = Color(0xFF2D2F30);
  static const onSurfaceVar = Color(0xFF5B5B5D);
}

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  String _gameMode = 'normal';
  File? _playerPhoto;
  final _picker = ImagePicker();
  final _roomCodeCtrl = TextEditingController();

  @override
  void dispose() {
    _roomCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 300,
        maxHeight: 300,
        imageQuality: 85,
      );

      if (picked != null && mounted) {
        final auth = context.read<AuthController>();
        setState(() => _playerPhoto = File(picked.path));
        auth.updatePfp(_playerPhoto!);
      }
    } catch (_) {}
  }

  void _showPhotoSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _C.onSurfaceVar.withAlpha(60),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Selecciona tu avatar',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _C.onBg,
              ),
            ),
            const SizedBox(height: 20),
            _photoOption(
              ctx,
              Icons.camera_alt_rounded,
              'Tomar foto',
              _C.secondary,
              ImageSource.camera,
            ),
            const SizedBox(height: 8),
            _photoOption(
              ctx,
              Icons.photo_library_rounded,
              'Galer\u00EDa',
              _C.tertiary,
              ImageSource.gallery,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _photoOption(
    BuildContext ctx,
    IconData icon,
    String label,
    Color color,
    ImageSource source,
  ) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: _C.onBg,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: _C.onSurfaceVar),
      onTap: () {
        Navigator.pop(ctx);
        _pickPhoto(source);
      },
    );
  }

  Future<void> _createRoom() async {
    final auth = context.read<AuthController>();
    final game = context.read<GameController>();
    final userId = auth.currentUser?.uid ?? '';
    final username = auth.currentUser?.username ?? 'Jugador';
    final code = createLobbyCode();

    await game.createRoom(code, userId, _gameMode);

    final shouldStart = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return Consumer<GameController>(
          builder: (context, gameProvider, child) {
            bool opponentJoined =
                gameProvider.currentGame?.oPlayer.isNotEmpty ?? false;

            String opponentName = gameProvider.oPlayerName;

            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(28),
              ),
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 40,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Navigator.of(dialogCtx).pop(false),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: _C.onSurfaceVar,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'C\u00F3digo de sala',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: _C.onSurfaceVar,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: _C.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SelectableText(
                        code,
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          color: _C.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Jugadores',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _C.onBg,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _playerWaitTag(
                      username,
                      _C.primary,
                      Icons.person_rounded,
                      true,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Icon(
                        Icons.add_rounded,
                        color: _C.onSurfaceVar.withAlpha(100),
                        size: 22,
                      ),
                    ),
                    opponentJoined
                        ? _playerWaitTag(
                            opponentName,
                            _C.secondary,
                            Icons.person_rounded,
                            true,
                          )
                        : _playerWaitTag(
                            'Esperando jugador\u2026',
                            _C.onSurfaceVar,
                            Icons.hourglass_top_rounded,
                            false,
                          ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: opponentJoined
                          ? () => Navigator.of(dialogCtx).pop(true)
                          : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: opponentJoined
                              ? _C.primary
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: opponentJoined
                              ? [
                                  BoxShadow(
                                    color: _C.primary.withAlpha(60),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_arrow_rounded,
                              color: opponentJoined
                                  ? Colors.white
                                  : _C.onSurfaceVar.withAlpha(100),
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Jugar',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: opponentJoined
                                    ? Colors.white
                                    : _C.onSurfaceVar.withAlpha(100),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (shouldStart == true && mounted) {
      await game.startGame();

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => GameScreen(roomCode: code, gameMode: _gameMode),
        ),
      );
    } else if (shouldStart == false) {
      await game.exitAndCleanRoom();
    }
  }

  Widget _playerWaitTag(String label, Color color, IconData icon, bool active) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: active ? color.withAlpha(20) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active ? color.withAlpha(80) : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: active ? color.withAlpha(30) : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: active ? _C.onBg : _C.onSurfaceVar.withAlpha(120),
              ),
            ),
          ),
          if (active) Icon(Icons.check_circle_rounded, color: color, size: 22),
        ],
      ),
    );
  }

  Future<void> _joinRoom() async {
    final code = _roomCodeCtrl.text.trim().toUpperCase();
    if (code.isEmpty) return;

    final auth = context.read<AuthController>();
    final userId = auth.currentUser?.uid ?? '';

    final joined = await context.read<GameController>().joinRoom(code, userId);

    if (!mounted) return;
    if (joined) {
      showDialog(
        context: context,
        builder: (dialogCtx) {
          return Consumer<GameController>(
            builder: (context, gameProvider, child) {
              final serverGameMode =
                  gameProvider.currentGame?.gamemode ?? _gameMode;

              if (gameProvider.currentGame?.state == 'playing') {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (Navigator.canPop(dialogCtx)) {
                    Navigator.of(dialogCtx).pop();
                  }
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          GameScreen(roomCode: code, gameMode: serverGameMode),
                    ),
                  );
                });
              }
              return Dialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(28),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: _C.primary),
                      const SizedBox(height: 20),
                      Text(
                        'Esperando al anfitrión...',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _C.onBg,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'La partida iniciará pronto.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: _C.onSurfaceVar,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sala no encontrada o ya est\u00E1 llena.',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: _C.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Widget _featureChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final username =
        context.watch<AuthController>().currentUser?.username ?? 'Jugador';

    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color(0xFFFDF8FA)),
          Positioned.fill(child: CustomPaint(painter: _SymbolsBgPainter())),
          SafeArea(
            child: Column(
              children: [
                _buildNav(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildGreeting(username),
                        const SizedBox(height: 14),
                        _buildAvatar(),
                        const SizedBox(height: 14),
                        _buildModes(),
                        const SizedBox(height: 14),
                        _buildRoom(),
                        const SizedBox(height: 16),
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

  Widget _navButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(230),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _C.primary.withAlpha(13)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Widget _buildNav() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Row(
        children: [
          _navButton(
            Icons.logout_rounded,
            _C.primary,
            () => context.read<AuthController>().logout(),
          ),
          const Spacer(),
          _navButton(
            Icons.history_rounded,
            _C.primary,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
          ),
          const SizedBox(width: 12),
          _navButton(
            Icons.emoji_events_rounded,
            const Color(0xFFFFD700),
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting(String username) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '\u00A1Hola, $username!',
                style: GoogleFonts.inter(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: _C.onBg,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '\u00BFListo para jugar?',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _C.onSurfaceVar.withAlpha(180),
                ),
              ),
            ],
          ),
        ),
        Image.asset(
          'assets/images/catprofile_sinfondo.png',
          width: 90,
          height: 90,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE0F2FE).withAlpha(230),
            const Color(0xFFDFF7FF).withAlpha(230),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withAlpha(128)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _showPhotoSheet,
            child: Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    image: DecorationImage(
                      image: _playerPhoto != null
                          ? FileImage(_playerPhoto!) as ImageProvider
                          : const AssetImage('assets/images/catprofile.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -1,
                  right: -1,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: _C.secondaryContainer,
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.photo_camera_rounded,
                      color: _C.secondary,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu Avatar',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _C.secondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Cambia tu foto para usarla como ficha',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: _C.secondary.withAlpha(180),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'MODO DE JUEGO',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _C.onSurfaceVar,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _modeCard(
                  'normal',
                  'Normal',
                  'Cl\u00E1sico',
                  Icons.sports_esports_rounded,
                  _C.tertiaryContainer.withAlpha(153),
                  _C.tertiary,
                ),
                const SizedBox(width: 12),
                _modeCard(
                  'math',
                  'Matem\u00E1tico',
                  'Resuelve',
                  Icons.calculate_rounded,
                  _C.secondaryContainer.withAlpha(153),
                  _C.secondary,
                ),
                const SizedBox(width: 12),
                _modeCard(
                  'infinite',
                  'Infinito',
                  'Sin fin',
                  Icons.all_inclusive_rounded,
                  _C.primaryContainer.withAlpha(102),
                  _C.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _modeCard(
    String mode,
    String title,
    String subtitle,
    IconData icon,
    Color bg,
    Color accent,
  ) {
    final sel = _gameMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _gameMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: sel ? accent : accent.withAlpha(26),
            width: sel ? 2.5 : 1,
          ),
          boxShadow: sel
              ? [
                  BoxShadow(
                    color: accent.withAlpha(40),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(180),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accent, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: accent,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 9,
                color: accent.withAlpha(153),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoom() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFCC9DF).withAlpha(230),
            const Color(0xFFF4C2D7).withAlpha(230),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withAlpha(102)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'SALA',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _C.primary,
                letterSpacing: 1.2,
              ),
            ),
          ),
          GestureDetector(
            onTap: _createRoom,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_rounded, color: _C.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Crear Sala',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _C.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Divider(color: _C.primary.withAlpha(50), height: 1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'O',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _C.primary.withAlpha(100),
                  ),
                ),
              ),
              Expanded(
                child: Divider(color: _C.primary.withAlpha(50), height: 1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(153),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: _roomCodeCtrl,
              textCapitalization: TextCapitalization.characters,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _C.primary,
                letterSpacing: 2,
              ),
              decoration: InputDecoration(
                hintText: 'C\u00F3digo de sala',
                hintStyle: GoogleFonts.inter(
                  color: _C.primary.withAlpha(77),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Icon(
                  Icons.door_sliding_outlined,
                  color: _C.primary.withAlpha(100),
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _joinRoom,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _C.primary,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _C.primary.withAlpha(50),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.login_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Unirse a Sala',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SymbolsBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);
    final symbols = ['X', 'O', '#'];
    final colors = [
      _C.primaryContainer.withAlpha(60),
      _C.secondaryContainer.withAlpha(70),
      _C.tertiaryContainer.withAlpha(70),
      _C.primary.withAlpha(18),
      _C.secondary.withAlpha(18),
    ];

    for (int i = 0; i < 35; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final symbol = symbols[rng.nextInt(symbols.length)];
      final color = colors[rng.nextInt(colors.length)];
      final fontSize = 18.0 + rng.nextDouble() * 28;
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
