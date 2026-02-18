import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/theme_provider.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await ref
            .read(authRepositoryProvider)
            .signIn(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );
      } catch (e) {
        if (!mounted) return;
        _showError(e.toString());
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Aesthetic (Animated-like Gradients)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.accent.withValues(alpha: 0.2),
                    Colors.black,
                    const Color(0xFF1E1B4B), // Dark Indigo
                  ],
                ),
              ),
            ),
          ),

          // Decorative Orbs
          Positioned(
            top: -100,
            right: -100,
            child: _buildOrb(theme.accent.withValues(alpha: 0.3), 300),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: _buildOrb(
              const Color(0xFF6366F1).withValues(alpha: 0.2),
              250,
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo / Title
                  _buildHeader(theme),
                  const SizedBox(height: 48),

                  // Glassmorphic Login Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        width: 450,
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(
                            alpha: theme.isDark ? 0.05 : 0.08,
                          ),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Hoş Geldiniz',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -1,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Hayallerine bir adım daha yaklaş',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 40),

                              _buildTextField(
                                controller: _emailController,
                                label: 'E-posta',
                                icon: CupertinoIcons.mail,
                                theme: theme,
                                validator: (v) => v != null && v.contains('@')
                                    ? null
                                    : 'Geçerli bir e-posta girin',
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                controller: _passwordController,
                                label: 'Şifre',
                                icon: CupertinoIcons.lock_fill,
                                theme: theme,
                                isPassword: true,
                                validator: (v) => v != null && v.length >= 6
                                    ? null
                                    : 'Şifre en az 6 karakter olmalı',
                              ),
                              const SizedBox(height: 32),

                              if (_isLoading)
                                const Center(child: CircularProgressIndicator())
                              else ...[
                                _buildPrimaryButton(
                                  onPressed: _login,
                                  label: 'Giriş Yap',
                                  theme: theme,
                                ),
                                const SizedBox(height: 16),
                                _buildGoogleButton(
                                  onPressed: _loginWithGoogle,
                                  theme: theme,
                                ),
                              ],

                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Hesabın yok mu?',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const RegisterScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Kayıt Ol',
                                      style: TextStyle(
                                        color: theme.accent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
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

  Widget _buildOrb(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color, blurRadius: size / 2, spreadRadius: size / 4),
        ],
      ),
    );
  }

  Widget _buildHeader(AppTheme theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.accent.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.accent.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Icon(
            CupertinoIcons.rocket_fill,
            color: theme.accent,
            size: 48,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'YKS Master',
          style: TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required AppTheme theme,
    required String? Function(String?) validator,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
        prefixIcon: Icon(
          icon,
          color: theme.accent.withValues(alpha: 0.7),
          size: 20,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required VoidCallback onPressed,
    required String label,
    required AppTheme theme,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        shadowColor: theme.accent.withValues(alpha: 0.5),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildGoogleButton({
    required VoidCallback onPressed,
    required AppTheme theme,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white, // Standard Google button white
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Official Google G Logo
            Image.network(
              'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1024px-Google_%22G%22_logo.svg.png',
              height: 24,
              width: 24,
            ),
            const SizedBox(width: 12),
            const Text(
              'Google ile Devam Et',
              style: TextStyle(
                color: Color(0xFF757575), // Standard Google text color
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
