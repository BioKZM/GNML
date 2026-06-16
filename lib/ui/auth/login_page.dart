import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:vault/Helper/auth.dart';
import 'package:vault/Providers/library_provider.dart';
import 'package:vault/ui/layout_scaffold.dart';
import 'package:intl/intl.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

enum AuthMode { login, register, forgotPassword }

class _LoginPageState extends State<LoginPage> {
  AuthMode _currentMode = AuthMode.login;
  AuthMode? _previousMode;
  final _formKey = GlobalKey<FormState>();
  bool _isEmailSent = false;
  bool _isLoading = false;
  String _errorMessage = "";

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  final AuthService _authService = AuthService();

  void _setMode(AuthMode mode) {
    setState(() {
      _previousMode = _currentMode;
      _currentMode = mode;
      _isEmailSent = false;
      _errorMessage = "";
      _formKey.currentState?.reset();
    });
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      if (_currentMode == AuthMode.login) {
        await _authService.signIn(
            _emailController.text, _passwordController.text);
      } else if (_currentMode == AuthMode.register) {
        String now = DateFormat('dd.MM.yyyy').format(DateTime.now());
        await _authService.registerENP(
          _usernameController.text,
          _emailController.text,
          _passwordController.text,
          now,
        );
      } else if (_currentMode == AuthMode.forgotPassword) {
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: _emailController.text);
        setState(() => _isEmailSent = true);
      }

      if (_currentMode != AuthMode.forgotPassword) {
        if (mounted) {
          final libraryProvider =
              Provider.of<LibraryProvider>(context, listen: false);
          await libraryProvider.init();
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LayoutScaffold()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? "An error occurred";
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSocialSignIn(Future<User?> Function() action) async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      final user = await action();
      if (user == null) {
        setState(() => _errorMessage = "Giriş iptal edildi.");
        return;
      }

      if (!mounted) return;
      final libraryProvider =
          Provider.of<LibraryProvider>(context, listen: false);
      await libraryProvider.init();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LayoutScaffold()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = e.message ?? "An error occurred");
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFCC0000);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(color: Color(0xFF121212)),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: (_currentMode == AuthMode.forgotPassword ||
                            _isEmailSent)
                        ? 480
                        : 850,
                  ),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: const Color(0xFF121212),
                    borderRadius: BorderRadius.circular(24),
                    border:
                        Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 600),
                        switchInCurve: Curves.easeInOutQuart,
                        switchOutCurve: Curves.easeInOutQuart,
                        transitionBuilder: (child, animation) {
                          final isEntering = child.key ==
                              ValueKey<Object>(
                                  _isEmailSent ? 'success' : _currentMode);
                          int getIndex(AuthMode m) {
                            switch (m) {
                              case AuthMode.login:
                                return 0;
                              case AuthMode.register:
                                return 1;
                              case AuthMode.forgotPassword:
                                return 2;
                            }
                          }

                          final currentIndex = getIndex(_currentMode);
                          final prevIndex =
                              getIndex(_previousMode ?? AuthMode.login);
                          double offsetValue =
                              (currentIndex >= prevIndex) ? 1.0 : -1.0;
                          if (!isEntering) offsetValue = -offsetValue;
                          return SlideTransition(
                            position: Tween<Offset>(
                                    begin: Offset(offsetValue, 0.0),
                                    end: Offset.zero)
                                .animate(animation),
                            child: FadeTransition(
                                opacity: animation, child: child),
                          );
                        },
                        child: Column(
                          key: ValueKey<Object>(
                              _isEmailSent ? 'success' : _currentMode),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              children: [
                                _isEmailSent
                                    ? const Icon(
                                        Icons.check_circle_outline_rounded,
                                        size: 80,
                                        color: Colors.green)
                                    : Lottie.asset(
                                        'assets/animations/Vault.json',
                                        width: 160,
                                        height: 160,
                                        fit: BoxFit.contain),
                                const SizedBox(height: 4),
                                Text(
                                  'VAULT',
                                  style: GoogleFonts.inter(
                                      fontSize: 40,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 8,
                                      color: primaryColor),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            if (_isEmailSent) ...[
                              Text("Bağlantı Gönderildi!",
                                  style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 12),
                              Text(
                                "Lütfen e-posta kutunuzu kontrol edin. Şifre sıfırlama bağlantısını oraya gönderdik.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400),
                              ),
                              const SizedBox(height: 32),
                              TextButton(
                                onPressed: () => _setMode(AuthMode.login),
                                style: TextButton.styleFrom(
                                  foregroundColor: primaryColor,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                        color: primaryColor.withValues(
                                            alpha: 0.3)),
                                  ),
                                ),
                                child: const Text('Giriş Ekranına Dön'),
                              ),
                            ] else if (_currentMode ==
                                AuthMode.forgotPassword) ...[
                              Text("Şifrenizi mi Unuttunuz?",
                                  style: GoogleFonts.inter(
                                      color:
                                          Colors.white.withValues(alpha: 0.9),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 12),
                              Text(
                                "E-posta adresinizi girin, size şifre sıfırlama bağlantı göndereceğiz.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400),
                              ),
                              const SizedBox(height: 32),
                              TextFormField(
                                controller: _emailController,
                                style: GoogleFonts.inter(fontSize: 14),
                                validator: (val) => (val == null || val.isEmpty)
                                    ? 'E-posta gerekli'
                                    : (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                            .hasMatch(val)
                                        ? 'Geçersiz e-posta'
                                        : null),
                                decoration: InputDecoration(
                                  hintText: 'E-posta adresi',
                                  prefixIcon: const Icon(Icons.email_outlined,
                                      size: 20),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                        color: Colors.white
                                            .withValues(alpha: 0.1)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                        color: Colors.white
                                            .withValues(alpha: 0.1)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide:
                                        const BorderSide(color: primaryColor),
                                  ),
                                  filled: true,
                                  fillColor:
                                      Colors.white.withValues(alpha: 0.05),
                                ),
                              ),
                              const SizedBox(height: 24),
                              _buildPrimaryButton(
                                label: 'BAĞLANTI GÖNDER',
                                onTap: _handleAuth,
                                isLoading: _isLoading,
                                primaryColor: primaryColor,
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                  onPressed: () => _setMode(AuthMode.login),
                                  child: const Text('Giriş ekranına dön')),
                            ] else ...[
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          if (_currentMode ==
                                              AuthMode.register) ...[
                                            TextFormField(
                                              controller: _usernameController,
                                              style: GoogleFonts.inter(
                                                  fontSize: 14),
                                              validator: (val) =>
                                                  (val == null || val.isEmpty)
                                                      ? 'Kullanıcı adı gerekli'
                                                      : (val.length < 3
                                                          ? 'En az 3 karakter'
                                                          : null),
                                              decoration: InputDecoration(
                                                hintText: 'Kullanıcı adı',
                                                prefixIcon: const Icon(
                                                    Icons.person_outline,
                                                    size: 20),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  borderSide: BorderSide(
                                                      color: Colors.white
                                                          .withValues(
                                                              alpha: 0.1)),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  borderSide: BorderSide(
                                                      color: Colors.white
                                                          .withValues(
                                                              alpha: 0.1)),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  borderSide: const BorderSide(
                                                      color: primaryColor),
                                                ),
                                                filled: true,
                                                fillColor: Colors.white
                                                    .withValues(alpha: 0.05),
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                          ],
                                          TextFormField(
                                            controller: _emailController,
                                            style:
                                                GoogleFonts.inter(fontSize: 14),
                                            validator: (val) => (val == null ||
                                                    val.isEmpty)
                                                ? 'E-posta gerekli'
                                                : (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                                        .hasMatch(val)
                                                    ? 'Geçersiz e-posta'
                                                    : null),
                                            decoration: InputDecoration(
                                              hintText: 'E-posta adresi',
                                              prefixIcon: const Icon(
                                                  Icons.email_outlined,
                                                  size: 20),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: BorderSide(
                                                    color: Colors.white
                                                        .withValues(
                                                            alpha: 0.1)),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: BorderSide(
                                                    color: Colors.white
                                                        .withValues(
                                                            alpha: 0.1)),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: const BorderSide(
                                                    color: primaryColor),
                                              ),
                                              filled: true,
                                              fillColor: Colors.white
                                                  .withValues(alpha: 0.05),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          TextFormField(
                                            controller: _passwordController,
                                            obscureText: true,
                                            style:
                                                GoogleFonts.inter(fontSize: 14),
                                            validator: (val) =>
                                                (val == null || val.isEmpty)
                                                    ? 'Şifre gerekli'
                                                    : (val.length < 6
                                                        ? 'En az 6 karakter'
                                                        : null),
                                            decoration: InputDecoration(
                                              hintText: 'Şifre',
                                              prefixIcon: const Icon(
                                                  Icons.lock_outline,
                                                  size: 20),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: BorderSide(
                                                    color: Colors.white
                                                        .withValues(
                                                            alpha: 0.1)),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: BorderSide(
                                                    color: Colors.white
                                                        .withValues(
                                                            alpha: 0.1)),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: const BorderSide(
                                                    color: primaryColor),
                                              ),
                                              filled: true,
                                              fillColor: Colors.white
                                                  .withValues(alpha: 0.05),
                                            ),
                                          ),
                                          if (_currentMode == AuthMode.login)
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: TextButton(
                                                  onPressed: () => _setMode(
                                                      AuthMode.forgotPassword),
                                                  child: const Text(
                                                      'Şifremi unuttum?')),
                                            ),
                                          if (_errorMessage.isNotEmpty)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8),
                                              child: Text(_errorMessage,
                                                  style: const TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 12)),
                                            ),
                                          const SizedBox(height: 48),
                                          const Spacer(),
                                          _buildPrimaryButton(
                                            label:
                                                _currentMode == AuthMode.login
                                                    ? 'GİRİŞ YAP'
                                                    : 'KAYIT OL',
                                            onTap: _handleAuth,
                                            isLoading: _isLoading,
                                            primaryColor: primaryColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 56),
                                      child: Column(
                                        children: [
                                          Expanded(
                                              child: Container(
                                                  width: 1,
                                                  color: Colors.white
                                                      .withValues(alpha: 0.1))),
                                          Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 28),
                                              child: Text("veya",
                                                  style: GoogleFonts.inter(
                                                      color: Colors.white
                                                          .withValues(
                                                              alpha: 0.3),
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500))),
                                          Expanded(
                                              child: Container(
                                                  width: 1,
                                                  color: Colors.white
                                                      .withValues(alpha: 0.1))),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          _buildAlternativeButton(
                                              icon:
                                                  Icons.person_outline_rounded,
                                              label: "ANONİM GİRİŞ",
                                              onTap: () {}),
                                          const SizedBox(height: 12),
                                          _buildAlternativeButton(
                                            icon: _currentMode == AuthMode.login
                                                ? Icons
                                                    .person_add_alt_1_outlined
                                                : Icons.login_outlined,
                                            label:
                                                _currentMode == AuthMode.login
                                                    ? "YENİ HESAP OLUŞTUR"
                                                    : "ZATEN ÜYEYİM",
                                            onTap: () => _setMode(
                                                _currentMode == AuthMode.login
                                                    ? AuthMode.register
                                                    : AuthMode.login),
                                          ),
                                          const SizedBox(height: 32),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              _buildSocialIcon(
                                                FontAwesomeIcons.google,
                                                () => _handleSocialSignIn(
                                                    _authService
                                                        .signInWithGoogle),
                                              ),
                                              const SizedBox(width: 12),
                                              _buildSocialIcon(
                                                FontAwesomeIcons.apple,
                                                () => _handleSocialSignIn(
                                                    _authService
                                                        .signInWithApple),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, VoidCallback onTap) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: _isLoading ? null : onTap,
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            child: Icon(icon,
                size: 30, color: Colors.white.withValues(alpha: 0.8))),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onTap,
    required bool isLoading,
    required Color primaryColor,
  }) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          splashFactory: NoSplash.splashFactory,
          highlightColor: primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    label,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlternativeButton(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: Colors.white.withValues(alpha: 0.6)),
              const SizedBox(width: 10),
              Text(label,
                  style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      height: 1.0)),
            ],
          ),
        ),
      ),
    );
  }
}
