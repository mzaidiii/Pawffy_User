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
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _phoneFocus = FocusNode();
  final _otpFocus = FocusNode();

  bool _rememberMe = true;
  bool _otpSent = false;

  String? _phoneError;
  String? _otpError;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _phoneFocus.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  String? _validatePhone(String value) {
    if (value.isEmpty) return 'Phone number is required';
    if (!value.startsWith('+')) return 'Must start with + and country code (e.g. +1)';
    if (value.length < 10) return 'Enter a valid phone number';
    return null;
  }

  String? _validateOtp(String value) {
    if (value.isEmpty) return 'OTP is required';
    if (value.length != 6) return 'OTP must be 6 digits';
    return null;
  }

  Future<void> _handleSendOtp() async {
    final phone = _phoneController.text.trim();
    final err = _validatePhone(phone);
    setState(() => _phoneError = err);
    if (err != null) return;

    final success = await ref
        .read(authControllerProvider.notifier)
        .sendOtp(phone: phone);

    if (!mounted) return;

    if (success) {
      setState(() => _otpSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent successfully. Please check your phone.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final error = ref.read(authControllerProvider);
      final errorMsg = error.hasError
          ? error.error.toString().replaceFirst('Exception: ', '')
          : 'Failed to send OTP';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.redAccent),
      );
    }
  }

  Future<void> _handleVerifyOtp() async {
    final phone = _phoneController.text.trim();
    final code = _otpController.text.trim();
    final err = _validateOtp(code);
    setState(() => _otpError = err);
    if (err != null) return;

    final accessToken = await ref
        .read(authControllerProvider.notifier)
        .verifyOtp(phone: phone, token: code);

    if (!mounted) return;

    if (accessToken != null) {
      final success = await ref
          .read(authControllerProvider.notifier)
          .loginWithOtpSession(accessToken: accessToken);

      if (!mounted) return;

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        final error = ref.read(authControllerProvider);
        final errorMsg = error.hasError
            ? error.error.toString().replaceFirst('Exception: ', '')
            : 'Session initialization failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.redAccent),
        );
      }
    } else {
      final error = ref.read(authControllerProvider);
      final errorMsg = error.hasError
          ? error.error.toString().replaceFirst('Exception: ', '')
          : 'OTP verification failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = true; // Always style as dark mode since the screen background is black
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.12),

                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'HELLO,',
                              style: GoogleFonts.archivoBlack(
                                fontSize: 52,
                                fontWeight: FontWeight.w400,
                                height: 1.0,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
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
                      ),
                      const SizedBox(height: 18),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'WELCOME BACK!',
                          style: GoogleFonts.archivoBlack(
                            fontSize: 35,
                            fontWeight: FontWeight.w400,
                            height: 1.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: size.height * 0.10),

                if (!_otpSent) ...[
                  _buildTextField(
                    controller: _phoneController,
                    focusNode: _phoneFocus,
                    hint: 'Phone Number (e.g. +15551234567)',
                    icon: Icons.phone_android_rounded,
                    errorText: _phoneError,
                    keyboardType: TextInputType.phone,
                    isDark: isDark,
                    onChanged: (_) {
                      if (_phoneError != null) {
                        setState(
                          () => _phoneError = _validatePhone(
                            _phoneController.text.trim(),
                          ),
                        );
                      }
                    },
                    onSubmitted: (_) => _handleSendOtp(),
                  ),
                  const SizedBox(height: 14),
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
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  ElevatedButton(
                    onPressed: authState.isLoading ? null : _handleSendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE85D04),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFE85D04).withOpacity(0.6),
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
                                'SEND OTP',
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
                ] else ...[
                  _buildTextField(
                    controller: _otpController,
                    focusNode: _otpFocus,
                    hint: 'Enter 6-Digit OTP',
                    icon: Icons.security_rounded,
                    errorText: _otpError,
                    keyboardType: TextInputType.number,
                    isDark: isDark,
                    onChanged: (_) {
                      if (_otpError != null) {
                        setState(
                          () => _otpError = _validateOtp(
                            _otpController.text.trim(),
                          ),
                        );
                      }
                    },
                    onSubmitted: (_) => _handleVerifyOtp(),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _otpSent = false;
                          _otpController.clear();
                        });
                      },
                      icon: const Icon(Icons.arrow_back_rounded, size: 16, color: Colors.grey),
                      label: Text(
                        'Change phone number',
                        style: GoogleFonts.barlow(
                          color: Colors.grey,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: authState.isLoading ? null : _handleVerifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE85D04),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFE85D04).withOpacity(0.6),
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
                                'VERIFY & LOGIN',
                                style: GoogleFonts.barlow(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.check_circle_outline_rounded, size: 18),
                            ],
                          ),
                  ),
                ],

                const SizedBox(height: 22),

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
                          color: Colors.white,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    FocusNode? focusNode,
    String? errorText,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
  }) {
    final fillColor = isDark ? const Color(0xFF232323) : const Color(0xFFF2F2F2);
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = Colors.grey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: TextInputAction.done,
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
}
