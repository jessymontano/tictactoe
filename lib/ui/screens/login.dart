import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/logic/auth_controller.dart';
import 'package:tictactoe/ui/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _onIniciar() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AuthSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Stack(
          children: [
            const _Decorations(),
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        const Spacer(flex: 2),
                        _buildGlowIcon(),
                        const SizedBox(height: 28),
                        _buildLogo(),
                        const SizedBox(height: 28),
                        Text(
                          'Gato',
                          style: GoogleFonts.inter(
                            fontSize: 46,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Universidad de Sonora',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: AppColors.accent,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 36),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: Column(
                            children: [
                              _buildFeatureCard(
                                Icons.all_inclusive_rounded,
                                'Modo Sin Fin',
                                'Tus fichas se borran hasta lograr 3 en l\u00EDnea',
                              ),
                              const SizedBox(height: 12),
                              _buildFeatureCard(
                                Icons.calculate_rounded,
                                'Reto matem\u00e1tico',
                                'Resuelve para colocar tu ficha',
                              ),
                              const SizedBox(height: 12),
                              _buildFeatureCard(
                                Icons.camera_alt_rounded,
                                'Foto como ficha',
                                'Usa tu cara como X u O',
                              ),
                            ],
                          ),
                        ),
                        const Spacer(flex: 3),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: _buildStartButton(),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Equipo',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white.withAlpha(90),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Arce Gaxiola Angel Eduardo',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white.withAlpha(90),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Montaño Lares Jessica',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white.withAlpha(90),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Valencia Valenzuela Frida Sofía',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white.withAlpha(90),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlowIcon() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.accent.withAlpha(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withAlpha(40),
            blurRadius: 30,
            spreadRadius: 8,
          ),
        ],
      ),
      child: const Icon(
        Icons.grid_3x3_rounded,
        color: AppColors.accent,
        size: 28,
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.accent.withAlpha(180), width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withAlpha(30),
            blurRadius: 28,
            spreadRadius: 4,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo_unison.png',
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            color: AppColors.backgroundMid,
            child: const Icon(Icons.school, size: 52, color: AppColors.accent),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accent.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withAlpha(140),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onTap: _onIniciar,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: AppColors.accentGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withAlpha(80),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Iniciar Gato',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.backgroundDark,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.grid_3x3_rounded,
              color: AppColors.backgroundDark,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom sheet de auth con colores del inicio ──

class _AuthSheet extends StatefulWidget {
  const _AuthSheet();

  @override
  State<_AuthSheet> createState() => _AuthSheetState();
}

class _AuthSheetState extends State<_AuthSheet> {
  bool _isLogin = false;
  bool _isLoading = false;
  bool _obscure = true;

  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _userCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthController>();
    setState(() => _isLoading = true);

    if (_isLogin) {
      await auth.login(_emailCtrl.text.trim(), _passCtrl.text.trim());
    } else {
      if (!_formKey.currentState!.validate()) {
        setState(() => _isLoading = false);
        return;
      }
      await auth.register(
        _emailCtrl.text.trim(),
        _passCtrl.text,
        _userCtrl.text.trim(),
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.pop(context);
  }

  String? _valUser(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingresa tu nombre de usuario';
    return null;
  }

  String? _valEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
    if (!RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) {
      return 'Correo no v\u00e1lido';
    }
    return null;
  }

  String? _valPass(String? v) {
    if (v == null || v.isEmpty) return 'Ingresa tu contrase\u00f1a';
    if (v.length < 6) return 'M\u00ednimo 6 caracteres';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D47A1), Color(0xFF081442)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 14, 28, 28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(50),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 22),
              _buildHeader(),
              const SizedBox(height: 24),
              _buildToggle(),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                child: _isLogin ? _loginFields() : _registerFields(),
              ),
              const SizedBox(height: 28),
              _buildSubmit(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.accent.withAlpha(30),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.accent.withAlpha(60)),
          ),
          child: const Icon(
            Icons.person_add_rounded,
            color: AppColors.accent,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isLogin ? 'Iniciar Sesi\u00f3n' : 'Crear Cuenta',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _isLogin
                    ? 'Ingresa tus datos para continuar'
                    : 'Completa el formulario para registrarte',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.white.withAlpha(150),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggle() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _tab('Registro', !_isLogin, () {
            if (_isLogin) setState(() => _isLogin = false);
          }),
          _tab('Iniciar Sesi\u00f3n', _isLogin, () {
            if (!_isLogin) setState(() => _isLogin = true);
          }),
        ],
      ),
    );
  }

  Widget _tab(String text, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: active ? AppColors.accentGradient : null,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.inter(
                color: active
                    ? AppColors.backgroundDark
                    : Colors.white.withAlpha(140),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _registerFields() {
    return Column(
      key: const ValueKey('register'),
      children: [
        _inputField(
          controller: _userCtrl,
          label: 'Nombre de usuario',
          hint: 'Ej: GatoMaster',
          icon: Icons.person_outline_rounded,
          validator: _valUser,
        ),
        const SizedBox(height: 14),
        _inputField(
          controller: _emailCtrl,
          label: 'Correo electr\u00f3nico',
          hint: 'correo@ejemplo.com',
          icon: Icons.email_outlined,
          keyboard: TextInputType.emailAddress,
          validator: _valEmail,
        ),
        const SizedBox(height: 14),
        _passwordField(),
      ],
    );
  }

  Widget _loginFields() {
    return Column(
      key: const ValueKey('login'),
      children: [
        _inputField(
          controller: _emailCtrl,
          label: 'Correo electr\u00f3nico',
          hint: 'correo@ejemplo.com',
          icon: Icons.email_outlined,
          keyboard: TextInputType.emailAddress,
          validator: _valEmail,
        ),
        const SizedBox(height: 14),
        _passwordField(),
      ],
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.accent, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white.withAlpha(200),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboard,
          validator: validator,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withAlpha(60),
            ),
            filled: true,
            fillColor: Colors.white.withAlpha(15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withAlpha(20)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withAlpha(20)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.xColor, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.xColor, width: 1.5),
            ),
            errorStyle: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.xColor,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _passwordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.accent,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Contrase\u00f1a',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white.withAlpha(200),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passCtrl,
          obscureText: _obscure,
          validator: _valPass,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: 'M\u00ednimo 6 caracteres',
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withAlpha(60),
            ),
            filled: true,
            fillColor: Colors.white.withAlpha(15),
            suffixIcon: IconButton(
              icon: Icon(
                _obscure
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: Colors.white.withAlpha(100),
                size: 20,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withAlpha(20)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withAlpha(20)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.xColor, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.xColor, width: 1.5),
            ),
            errorStyle: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.xColor,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmit() {
    return GestureDetector(
      onTap: _isLoading ? null : _submit,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: AppColors.accentGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withAlpha(60),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.backgroundDark,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLogin ? 'Iniciar Sesi\u00f3n' : 'Registrarse',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.backgroundDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.backgroundDark,
                      size: 20,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── Decoraciones de fondo ──

class _Decorations extends StatelessWidget {
  const _Decorations();

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Positioned(
          top: h * 0.15,
          left: -70,
          child: _ring(300, Colors.white.withAlpha(10), 1.5),
        ),
        Positioned(
          top: h * 0.10,
          right: -90,
          child: _ring(340, Colors.white.withAlpha(7), 1),
        ),
        Positioned(
          top: -50,
          right: -30,
          child: _blob(150, AppColors.primary.withAlpha(22)),
        ),
        Positioned(
          bottom: 140,
          left: -40,
          child: _blob(110, AppColors.accent.withAlpha(12)),
        ),
        Positioned(
          top: h * 0.65,
          right: -20,
          child: _blob(80, AppColors.oColor.withAlpha(10)),
        ),

        // # symbols
        _icon(h * 0.08, null, w * 0.12, null, Icons.tag, 50, -0.2, 0.05),
        _icon(h * 0.52, null, null, 16, Icons.tag, 70, 0.3, 0.045),
        _icon(null, h * 0.22, 20, null, Icons.tag, 55, 0.15, 0.04),
        _icon(h * 0.35, null, null, w * 0.35, Icons.tag, 40, -0.4, 0.03),

        // X symbols
        _icon(h * 0.22, null, null, 30, Icons.close_rounded, 44, 0.25, 0.05),
        _icon(
          h * 0.60,
          null,
          w * 0.15,
          null,
          Icons.close_rounded,
          36,
          -0.3,
          0.04,
        ),
        _icon(
          null,
          h * 0.08,
          null,
          w * 0.25,
          Icons.close_rounded,
          28,
          0.5,
          0.035,
        ),

        // O symbols
        _icon(h * 0.42, null, 24, null, Icons.circle_outlined, 40, 0, 0.045),
        _icon(
          h * 0.70,
          null,
          null,
          w * 0.10,
          Icons.circle_outlined,
          32,
          0,
          0.04,
        ),
        _icon(
          h * 0.12,
          null,
          null,
          w * 0.22,
          Icons.circle_outlined,
          24,
          0,
          0.03,
        ),

        // Grid grande
        _icon(
          h * 0.30,
          null,
          null,
          w * 0.60,
          Icons.grid_3x3_rounded,
          90,
          0.15,
          0.025,
        ),
      ],
    );
  }

  Widget _ring(double size, Color color, double width) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: width),
      ),
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _icon(
    double? top,
    double? bottom,
    double? left,
    double? right,
    IconData icon,
    double size,
    double angle,
    double opacity,
  ) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Transform.rotate(
        angle: angle,
        child: Opacity(
          opacity: opacity,
          child: Icon(icon, size: size, color: Colors.white),
        ),
      ),
    );
  }
}
