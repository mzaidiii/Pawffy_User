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
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _agreeToTerms = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
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

  String? _validatePassword(String value) {
    if (value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Za-z]').hasMatch(value))
      return 'Must contain at least one letter';
    if (!RegExp(r'\d').hasMatch(value))
      return 'Must contain at least one number';
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Must contain at least one special character';
    }
    return null;
  }

  String? _validateConfirmPassword(String value) {
    if (value.isEmpty) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  bool _validateAll() {
    final nameErr = _validateName(_nameController.text.trim());
    final emailErr = _validateEmail(_emailController.text.trim());
    final passErr = _validatePassword(_passwordController.text);
    final confirmErr = _validateConfirmPassword(
      _confirmPasswordController.text,
    );
    setState(() {
      _nameError = nameErr;
      _emailError = emailErr;
      _passwordError = passErr;
      _confirmPasswordError = confirmErr;
    });
    return nameErr == null &&
        emailErr == null &&
        passErr == null &&
        confirmErr == null;
  }

  Future<void> _handleSignUp() async {
    if (!_validateAll()) return;

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept Terms & Conditions')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await ref
        .read(authControllerProvider.notifier)
        .register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProfileSetupScreen()),
      );
    } else {
      final error = ref.read(authControllerProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.hasError
                ? error.error.toString().replaceFirst('Exception: ', '')
                : 'Registration failed',
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

    return Scaffold(
      backgroundColor: scaffoldBg,
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
                child: Icon(
                  Icons.arrow_back,
                  color: isDark ? Colors.white : Colors.black,
                  size: 24,
                ),
              ),

              SizedBox(height: size.height * 0.04),

              Text(
                'CREATE',
                style: GoogleFonts.archivoBlack(
                  fontSize: 58,
                  fontWeight: FontWeight.w400,
                  height: 0.95,
                  color: isDark ? Colors.white : Colors.black,
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
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? const Color(0xFFE0E0E0)
                      : const Color(0xFF666666),
                ),
              ),

              SizedBox(height: size.height * 0.04),

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
                onSubmitted: (_) => _passwordFocus.requestFocus(),
              ),
              const SizedBox(height: 14),

              _buildTextField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                hint: 'Password',
                icon: Icons.lock_outline,
                errorText: _passwordError,
                isPassword: true,
                obscure: _obscurePassword,
                isDark: isDark,
                onToggle: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                onChanged: (_) {
                  if (_passwordError != null) {
                    setState(
                      () => _passwordError = _validatePassword(
                        _passwordController.text,
                      ),
                    );
                  }
                  if (_confirmPasswordError != null) {
                    setState(
                      () => _confirmPasswordError = _validateConfirmPassword(
                        _confirmPasswordController.text,
                      ),
                    );
                  }
                },
                onSubmitted: (_) => _confirmPasswordFocus.requestFocus(),
              ),
              const SizedBox(height: 14),

              _buildTextField(
                controller: _confirmPasswordController,
                focusNode: _confirmPasswordFocus,
                hint: 'Confirm Password',
                icon: Icons.lock_outline,
                errorText: _confirmPasswordError,
                isPassword: true,
                obscure: _obscureConfirmPassword,
                isDark: isDark,
                onToggle: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                ),
                onChanged: (_) {
                  if (_confirmPasswordError != null) {
                    setState(
                      () => _confirmPasswordError = _validateConfirmPassword(
                        _confirmPasswordController.text,
                      ),
                    );
                  }
                },
                onSubmitted: (_) => _handleSignUp(),
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
                        color: isDark ? Colors.white : Colors.black87,
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
                onPressed: _isLoading ? null : _handleSignUp,
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
                            'SIGN UP',
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
              const SizedBox(height: 20),

              Center(
                child: Text(
                  'Or Sign Up With',
                  style: GoogleFonts.barlow(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 16),

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
              const SizedBox(height: 32),

              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: GoogleFonts.barlow(
                          color: isDark ? Colors.white : Colors.black87,
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
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggle,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
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
          obscureText: isPassword ? obscure : false,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          textInputAction: isPassword && hint == 'Confirm Password'
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
                      obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: hintColor,
                      size: 20,
                    ),
                    onPressed: onToggle,
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
