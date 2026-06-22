import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pawffy/features/auth/signUpScreen.dart';
import 'package:pawffy/features/home/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pawffy/features/auth/providers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _rememberMe = true;
  bool _obscurePassword = true;

  // Validation state
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // ── US-specific validators ─────────────────────────────────────────────────
  String? _validateEmail(String value) {
    if (value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w\.\+\-]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  bool _validateAll() {
    final emailErr = _validateEmail(_emailController.text.trim());
    final passErr = _validatePassword(_passwordController.text);
    setState(() {
      _emailError = emailErr;
      _passwordError = passErr;
    });
    return emailErr == null && passErr == null;
  }

  // ── Login handler ──────────────────────────────────────────────────────────
  Future<void> _handleLogin() async {
    if (!_validateAll()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final success = await ref
        .read(authControllerProvider.notifier)
        .login(email: email, password: password);

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      final error = ref.read(authControllerProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.hasError
                ? error.error.toString().replaceFirst('Exception: ', '')
                : 'Login failed',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDark = brightness == Brightness.dark;
    final scaffoldBg = isDark ? Colors.black : Colors.white;
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: scaffoldBg,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Top spacer ─────────────────────────────────────────────────
                SizedBox(height: size.height * 0.12),

                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Line 1: HELLO, + dog image as inline badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'HELLO,',
                            style: GoogleFonts.archivoBlack(
                              fontSize: 52,
                              fontWeight: FontWeight.w400,
                              height: 1.0,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Dog image in a rounded orange pill/badge
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              'android/assets/LoginDog.png',
                              width: 102,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 105,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE85D04),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 18),
                      // Line 2: WELCOME BACK! full width
                      Text(
                        'WELCOME BACK!',
                        style: GoogleFonts.archivoBlack(
                          fontSize: 35,
                          fontWeight: FontWeight.w400,
                          height: 1.0,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: size.height * 0.10),

                // ── Email Field ────────────────────────────────────────────────
                _buildTextField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  hint: 'Email Address',
                  icon: Icons.mail_outline,
                  errorText: _emailError,
                  keyboardType: TextInputType.emailAddress,
                  isDark: isDark,
                  onChanged: (_) {
                    if (_emailError != null) {
                      setState(
                        () => _emailError = _validateEmail(
                          _emailController.text.trim(),
                        ),
                      );
                    }
                  },
                  onSubmitted: (_) => _passwordFocus.requestFocus(),
                ),
                const SizedBox(height: 14),

                // ── Password Field ─────────────────────────────────────────────
                _buildTextField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  hint: 'Password',
                  icon: Icons.lock_outline,
                  errorText: _passwordError,
                  isPassword: true,
                  isDark: isDark,
                  onChanged: (_) {
                    if (_passwordError != null) {
                      setState(
                        () => _passwordError = _validatePassword(
                          _passwordController.text,
                        ),
                      );
                    }
                  },
                  onSubmitted: (_) => _handleLogin(),
                ),
                const SizedBox(height: 14),

                // ── Remember Me + Forgot Password ──────────────────────────────
                Row(
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: (val) => setState(() => _rememberMe = val!),
                        activeColor: const Color(0xFFE85D04),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        side: const BorderSide(
                          color: Color(0xFFE85D04),
                          width: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Remember me',
                      style: GoogleFonts.barlow(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.barlow(
                          color: const Color(0xFFE85D04),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // ── LOG IN Button ──────────────────────────────────────────────
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE85D04),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(
                      0xFFE85D04,
                    ).withOpacity(0.6),
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'LOG IN',
                              style: GoogleFonts.barlow(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_outward, size: 18),
                          ],
                        ),
                ),
                const SizedBox(height: 22),

                // ── Or Log In With ─────────────────────────────────────────────
                Text(
                  'Or Log In With',
                  style: GoogleFonts.barlow(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Social Buttons ─────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(
                      'G',
                      const Color(0xFF4285F4),
                      isDark: isDark,
                    ),
                    const SizedBox(width: 16),
                    _buildSocialButton(
                      '',
                      const Color(0xFF000000),
                      icon: Icons.apple,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 16),
                    _buildSocialButton(
                      'f',
                      const Color(0xFF1877F2),
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // ── Create Account Link ────────────────────────────────────────
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: GoogleFonts.barlow(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                        children: [
                          TextSpan(
                            text: 'Create account',
                            style: GoogleFonts.barlow(
                              color: const Color(0xFFE85D04),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Reusable Text Field ────────────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    FocusNode? focusNode,
    String? errorText,
    bool isPassword = false,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
  }) {
    final fillColor = isDark
        ? const Color(0xFF232323)
        : const Color(0xFFF2F2F2);
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = Colors.grey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          focusNode: focusNode,
          obscureText: isPassword ? _obscurePassword : false,
          keyboardType: keyboardType,
          textInputAction: isPassword
              ? TextInputAction.done
              : TextInputAction.next,
          style: GoogleFonts.barlow(color: textColor),
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.barlow(
              color: hintColor,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(icon, color: hintColor, size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: hintColor,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  )
                : null,
            filled: true,
            fillColor: fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: errorText != null
                  ? const BorderSide(color: Colors.redAccent, width: 1.2)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: errorText != null
                  ? const BorderSide(color: Colors.redAccent, width: 1.5)
                  : const BorderSide(color: Color(0xFFE85D04), width: 1.5),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              errorText,
              style: GoogleFonts.barlow(
                color: Colors.redAccent,
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Social Button ──────────────────────────────────────────────────────────
  Widget _buildSocialButton(
    String label,
    Color color, {
    IconData? icon,
    required bool isDark,
  }) {
    final bgColor = isDark ? const Color(0xFF232323) : const Color(0xFFF2F2F2);
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: icon != null
            ? Icon(
                icon,
                color: isDark ? Colors.white : Colors.black87,
                size: 26,
              )
            : Text(
                label,
                style: GoogleFonts.barlow(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}
