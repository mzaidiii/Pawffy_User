import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_setup_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pawffy/features/auth/providers/auth_controller.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _otpFocus = FocusNode();

  bool _agreeToTerms = true;
  bool _otpSent = false;
  bool _isLoading = false;

  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _otpError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  String? _validateName(String value) {
    if (value.isEmpty) return 'Full name is required';
    if (value.trim().length < 4) return 'Name must be at least 4 characters';
    return null;
  }

  String? _validateEmail(String value) {
    if (value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w\.\+\-]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
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

  bool _validateInputFields() {
    final nameErr = _validateName(_nameController.text.trim());
    final emailErr = _validateEmail(_emailController.text.trim());
    final phoneErr = _validatePhone(_phoneController.text.trim());
    setState(() {
      _nameError = nameErr;
      _emailError = emailErr;
      _phoneError = phoneErr;
    });
    return nameErr == null && emailErr == null && phoneErr == null;
  }

  Future<void> _handleSendOtp() async {
    if (!_validateInputFields()) return;

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept Terms & Conditions')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await ref
        .read(authControllerProvider.notifier)
        .sendOtp(phone: _phoneController.text.trim());

    if (!mounted) return;
    setState(() => _isLoading = false);

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

    setState(() => _isLoading = true);

    final accessToken = await ref
        .read(authControllerProvider.notifier)
        .verifyOtp(phone: phone, token: code);

    if (!mounted) return;

    if (accessToken != null) {
      final success = await ref
          .read(authControllerProvider.notifier)
          .loginWithOtpSession(
            accessToken: accessToken,
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
          );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ProfileSetupScreen()),
        );
      } else {
        final error = ref.read(authControllerProvider);
        final errorMsg = error.hasError
            ? error.error.toString().replaceFirst('Exception: ', '')
            : 'Session registration failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.redAccent),
        );
      }
    } else {
      setState(() => _isLoading = false);
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
    final isDark = true;

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
              ),

              SizedBox(height: size.height * 0.04),

              Text(
                'CREATE',
                style: GoogleFonts.archivoBlack(
                  fontSize: 58,
                  fontWeight: FontWeight.w400,
                  height: 0.95,
                  color: Colors.white,
                ),
              ),
              Text(
                'ACCOUNT!',
                style: GoogleFonts.archivoBlack(
                  fontSize: 52,
                  fontWeight: FontWeight.w400,
                  height: 0.95,
                  color: const Color(0xFFE85D04),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Let's get started with your details",
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFE0E0E0),
                ),
              ),

              SizedBox(height: size.height * 0.04),

              if (!_otpSent) ...[
                _buildTextField(
                  controller: _nameController,
                  focusNode: _nameFocus,
                  hint: 'Full Name',
                  icon: Icons.person_outline,
                  errorText: _nameError,
                  keyboardType: TextInputType.name,
                  isDark: isDark,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (_) {
                    if (_nameError != null) {
                      setState(
                        () => _nameError = _validateName(
                          _nameController.text.trim(),
                        ),
                      );
                    }
                  },
                  onSubmitted: (_) => _emailFocus.requestFocus(),
                ),
                const SizedBox(height: 14),

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
                  onSubmitted: (_) => _phoneFocus.requestFocus(),
                ),
                const SizedBox(height: 14),

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
                const SizedBox(height: 16),
                Row(
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: _agreeToTerms,
                        onChanged: (val) => setState(() => _agreeToTerms = val!),
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
                    RichText(
                      text: TextSpan(
                        text: 'I agree to the ',
                        style: GoogleFonts.barlow(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                        children: [
                          TextSpan(
                            text: 'Terms & Conditions',
                            style: GoogleFonts.barlow(
                              color: const Color(0xFFE85D04),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE85D04),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
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
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _otpSent = false;
                      _otpController.clear();
                    });
                  },
                  icon: const Icon(Icons.arrow_back_rounded, size: 16, color: Colors.grey),
                  label: Text(
                    'Change details / phone number',
                    style: GoogleFonts.barlow(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleVerifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE85D04),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
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
                              'VERIFY & REGISTER',
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

              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: GoogleFonts.barlow(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                        children: [
                          TextSpan(
                            text: 'Login',
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
              ),
            ],
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
    TextCapitalization textCapitalization = TextCapitalization.none,
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
          textCapitalization: textCapitalization,
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
