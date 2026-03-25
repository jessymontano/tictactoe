import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/core/utils.dart';
import 'package:tictactoe/logic/auth_controller.dart';
import 'package:tictactoe/logic/game_controller.dart';
import 'package:tictactoe/ui/screens/dashboard_screen.dart';
import 'package:tictactoe/ui/screens/game_screen.dart';
import 'package:tictactoe/ui/theme/app_theme.dart';

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
        setState(() => _playerPhoto = File(picked.path));
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
                color: AppColors.pTextLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text('Selecciona tu avatar',
                style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.pTextDark)),
            const SizedBox(height: 20),
            _photoOption(ctx, Icons.camera_alt_rounded, 'Tomar foto',
                AppColors.pPurpleDeep, ImageSource.camera),
            const SizedBox(height: 8),
            _photoOption(ctx, Icons.photo_library_rounded, 'Galer\u00EDa',
                AppColors.pGreen, ImageSource.gallery),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _photoOption(BuildContext ctx, IconData icon, String label,
      Color color, ImageSource source) {
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
      title: Text(label,
          style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.pTextDark)),
      trailing: Icon(Icons.chevron_right, color: AppColors.pTextLight),
      onTap: () {
        Navigator.pop(ctx);
        _pickPhoto(source);
      },
    );
  }

  Future<void> _createRoom() async {
    final auth = context.read<AuthController>();
    final username = auth.currentUser?.username ?? 'Jugador';
    final code = createLobbyCode();

    final shouldStart = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        bool opponentJoined = false;

        return StatefulBuilder(
          builder: (context, setDialogState) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28)),
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
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
                        child: const Icon(Icons.close_rounded,
                            color: AppColors.pTextMid, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('C\u00F3digo de sala',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: AppColors.pTextMid)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 24),
                    decoration: BoxDecoration(
                      color: AppColors.pLavender,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SelectableText(code,
                        style: GoogleFonts.inter(
                            fontSize: 32,
                            color: AppColors.pPurpleDeep,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 6)),
                  ),
                  const SizedBox(height: 24),
                  Text('Jugadores',
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.pTextDark)),
                  const SizedBox(height: 14),
                  _playerWaitTag(
                    username,
                    AppColors.pCoral,
                    Icons.person_rounded,
                    true,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Icon(Icons.add_rounded,
                        color: AppColors.pTextLight, size: 22),
                  ),
                  opponentJoined
                      ? _playerWaitTag(
                          'Oponente',
                          AppColors.pTeal,
                          Icons.person_rounded,
                          true,
                        )
                      : _playerWaitTag(
                          'Esperando jugador\u2026',
                          AppColors.pTextLight,
                          Icons.hourglass_top_rounded,
                          false,
                        ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () => Navigator.of(dialogCtx).pop(true),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: opponentJoined
                          ? AppTheme.pastelButton
                          : BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(16),
                            ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow_rounded,
                              color: opponentJoined
                                  ? Colors.white
                                  : AppColors.pTextLight,
                              size: 24),
                          const SizedBox(width: 8),
                          Text('Jugar',
                              style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: opponentJoined
                                      ? Colors.white
                                      : AppColors.pTextLight)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (shouldStart == true && mounted) {
      final auth = context.read<AuthController>();
      final userId = auth.currentUser?.uid ?? '';

      context.read<GameController>().startLocalGame(
            code,
            userId,
            'opponent',
            _gameMode,
          );

      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => GameScreen(
          roomCode: code,
          gameMode: _gameMode,
          playerPhoto: _playerPhoto,
        ),
      ));
    }
  }

  Widget _playerWaitTag(
      String label, Color color, IconData icon, bool active) {
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
            child: Text(label,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color:
                        active ? AppColors.pTextDark : AppColors.pTextLight)),
          ),
          if (active)
            Icon(Icons.check_circle_rounded, color: color, size: 22),
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
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => GameScreen(
          roomCode: code,
          gameMode: _gameMode,
          playerPhoto: _playerPhoto,
        ),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Sala no encontrada o ya est\u00E1 llena.',
            style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: AppColors.pCoral,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  Widget _circleIcon(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: AppTheme.circleButton,
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final username =
        context.watch<AuthController>().currentUser?.username ?? 'Jugador';
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.pGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildGreeting(username),
                      const SizedBox(height: 24),
                      _buildPhotoSection(),
                      const SizedBox(height: 18),
                      _buildModeSection(),
                      const SizedBox(height: 18),
                      _buildRoomSection(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Text(
            'Gato',
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.pPurpleDeep,
            ),
          ),
          const Spacer(),
          _circleIcon(
            Icons.emoji_events_rounded,
            AppColors.pYellow,
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const DashboardScreen())),
          ),
          const SizedBox(width: 10),
          _circleIcon(
            Icons.logout_rounded,
            AppColors.pTextMid,
            () => context.read<AuthController>().logout(),
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
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.pTextDark,
                ),
              ),
              const SizedBox(height: 2),
              Text('\u00BFListo para jugar?',
                  style: GoogleFonts.inter(
                      fontSize: 15, color: AppColors.pTextMid)),
            ],
          ),
        ),
        Image.asset(
          'assets/images/cat_icon.png',
          width: 60,
          height: 60,
          errorBuilder: (_, __, ___) =>
              const Text('\u{1F431}', style: TextStyle(fontSize: 44)),
        ),
      ],
    );
  }

  Widget _buildPhotoSection() {
    return Container(
      decoration: AppTheme.pastelCard(AppColors.pBlueBg),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: _showPhotoSheet,
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.pBlue, width: 3),
                color: Colors.white,
                image: _playerPhoto != null
                    ? DecorationImage(
                        image: FileImage(_playerPhoto!), fit: BoxFit.cover)
                    : null,
              ),
              child: _playerPhoto == null
                  ? const Icon(Icons.camera_alt_rounded,
                      color: AppColors.pBlue, size: 28)
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tu Avatar',
                    style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.pTextDark)),
                const SizedBox(height: 4),
                Text(
                  _playerPhoto != null
                      ? 'Toca para cambiar tu foto'
                      : 'Toma una foto para usar como ficha',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.pTextMid),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSection() {
    return Container(
      decoration: AppTheme.pastelCard(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Modo de Juego',
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.pTextDark)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                  child: _modeCard('normal', 'Normal',
                      Icons.gamepad_outlined, 'Cl\u00E1sico',
                      AppColors.pGreenBg, AppColors.pGreen)),
              const SizedBox(width: 8),
              Expanded(
                  child: _modeCard('math', 'Matem\u00E1tico',
                      Icons.calculate_outlined, 'Resuelve',
                      AppColors.pLavender, AppColors.pPurple)),
              const SizedBox(width: 8),
              Expanded(
                  child: _modeCard('infinite', 'Infinito',
                      Icons.all_inclusive_rounded, 'Sin fin',
                      AppColors.pYellowBg, AppColors.pYellow)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _modeCard(String mode, String title, IconData icon, String subtitle,
      Color bg, Color accentColor) {
    final sel = _gameMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _gameMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: sel ? bg : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: sel ? accentColor : Colors.transparent, width: 2.5),
          boxShadow: sel
              ? [BoxShadow(color: accentColor.withAlpha(40), blurRadius: 10, offset: const Offset(0, 3))]
              : [],
        ),
        child: Column(
          children: [
            Icon(icon,
                color: sel ? accentColor : AppColors.pTextLight, size: 30),
            const SizedBox(height: 8),
            Text(title,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: sel ? AppColors.pTextDark : AppColors.pTextLight)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: GoogleFonts.inter(
                    fontSize: 10, color: AppColors.pTextMid),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomSection() {
    return Container(
      decoration: AppTheme.pastelCard(AppColors.pPinkBg),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sala',
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.pTextDark)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _createRoom,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: AppTheme.pastelButton,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Text('Crear Sala',
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: Divider(color: AppColors.pTextLight.withAlpha(120))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text('o',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.pTextMid,
                        fontWeight: FontWeight.w500)),
              ),
              Expanded(
                  child: Divider(color: AppColors.pTextLight.withAlpha(120))),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _roomCodeCtrl,
            textCapitalization: TextCapitalization.characters,
            style: GoogleFonts.inter(
                color: AppColors.pTextDark,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 2),
            decoration: AppTheme.pastelInput(
              label: 'C\u00F3digo de sala',
              icon: Icons.meeting_room_outlined,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _joinRoom,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.pPurpleDeep, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.pPurpleDeep.withAlpha(30),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.login_rounded,
                      color: AppColors.pPurpleDeep, size: 22),
                  const SizedBox(width: 8),
                  Text('Unirse a Sala',
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.pPurpleDeep)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
