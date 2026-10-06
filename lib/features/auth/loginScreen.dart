import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pawffy/features/auth/signUpScreen.dart';
import 'package:pawffy/features/home/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pawffy/features/auth/providers/auth_controller.dart';

class Country {
  final String name;
  final String code;
  final String dialCode;

  const Country({
    required this.name,
    required this.code,
    required this.dialCode,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Country &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          dialCode == other.dialCode;

  @override
  int get hashCode => code.hashCode ^ dialCode.hashCode;
}

const List<Country> _countries = [
  Country(name: 'United States', code: 'US', dialCode: '+1'),
  Country(name: 'United Kingdom', code: 'GB', dialCode: '+44'),
  Country(name: 'Canada', code: 'CA', dialCode: '+1'),
  Country(name: 'India', code: 'IN', dialCode: '+91'),
  Country(name: 'Australia', code: 'AU', dialCode: '+61'),
  Country(name: 'Afghanistan', code: 'AF', dialCode: '+93'),
  Country(name: 'Albania', code: 'AL', dialCode: '+355'),
  Country(name: 'Algeria', code: 'DZ', dialCode: '+213'),
  Country(name: 'Argentina', code: 'AR', dialCode: '+54'),
  Country(name: 'Austria', code: 'AT', dialCode: '+43'),
  Country(name: 'Bahrain', code: 'BH', dialCode: '+973'),
  Country(name: 'Bangladesh', code: 'BD', dialCode: '+880'),
  Country(name: 'Belgium', code: 'BE', dialCode: '+32'),
  Country(name: 'Brazil', code: 'BR', dialCode: '+55'),
  Country(name: 'Chile', code: 'CL', dialCode: '+56'),
  Country(name: 'China', code: 'CN', dialCode: '+86'),
  Country(name: 'Colombia', code: 'CO', dialCode: '+57'),
  Country(name: 'Czech Republic', code: 'CZ', dialCode: '+420'),
  Country(name: 'Denmark', code: 'DK', dialCode: '+45'),
  Country(name: 'Egypt', code: 'EG', dialCode: '+20'),
  Country(name: 'Finland', code: 'FI', dialCode: '+358'),
  Country(name: 'France', code: 'FR', dialCode: '+33'),
  Country(name: 'Germany', code: 'DE', dialCode: '+49'),
  Country(name: 'Greece', code: 'GR', dialCode: '+30'),
  Country(name: 'Hong Kong', code: 'HK', dialCode: '+852'),
  Country(name: 'Hungary', code: 'HU', dialCode: '+36'),
  Country(name: 'Indonesia', code: 'ID', dialCode: '+62'),
  Country(name: 'Ireland', code: 'IE', dialCode: '+353'),
  Country(name: 'Israel', code: 'IL', dialCode: '+972'),
  Country(name: 'Italy', code: 'IT', dialCode: '+39'),
  Country(name: 'Japan', code: 'JP', dialCode: '+81'),
  Country(name: 'Jordan', code: 'JO', dialCode: '+962'),
  Country(name: 'Kenya', code: 'KE', dialCode: '+254'),
  Country(name: 'Kuwait', code: 'KW', dialCode: '+965'),
  Country(name: 'Lebanon', code: 'LB', dialCode: '+961'),
  Country(name: 'Malaysia', code: 'MY', dialCode: '+60'),
  Country(name: 'Mexico', code: 'MX', dialCode: '+52'),
  Country(name: 'Morocco', code: 'MA', dialCode: '+212'),
  Country(name: 'Nepal', code: 'NP', dialCode: '+977'),
  Country(name: 'Netherlands', code: 'NL', dialCode: '+31'),
  Country(name: 'New Zealand', code: 'NZ', dialCode: '+64'),
  Country(name: 'Nigeria', code: 'NG', dialCode: '+234'),
  Country(name: 'Norway', code: 'NO', dialCode: '+47'),
  Country(name: 'Oman', code: 'OM', dialCode: '+968'),
  Country(name: 'Pakistan', code: 'PK', dialCode: '+92'),
  Country(name: 'Peru', code: 'PE', dialCode: '+51'),
  Country(name: 'Philippines', code: 'PH', dialCode: '+63'),
  Country(name: 'Poland', code: 'PL', dialCode: '+48'),
  Country(name: 'Portugal', code: 'PT', dialCode: '+351'),
  Country(name: 'Qatar', code: 'QA', dialCode: '+974'),
  Country(name: 'Romania', code: 'RO', dialCode: '+40'),
  Country(name: 'Russia', code: 'RU', dialCode: '+7'),
  Country(name: 'Saudi Arabia', code: 'SA', dialCode: '+966'),
  Country(name: 'Singapore', code: 'SG', dialCode: '+65'),
  Country(name: 'South Africa', code: 'ZA', dialCode: '+27'),
  Country(name: 'South Korea', code: 'KR', dialCode: '+82'),
  Country(name: 'Spain', code: 'ES', dialCode: '+34'),
  Country(name: 'Sri Lanka', code: 'LK', dialCode: '+94'),
  Country(name: 'Sweden', code: 'SE', dialCode: '+46'),
  Country(name: 'Switzerland', code: 'CH', dialCode: '+41'),
  Country(name: 'Taiwan', code: 'TW', dialCode: '+886'),
  Country(name: 'Thailand', code: 'TH', dialCode: '+66'),
  Country(name: 'Turkey', code: 'TR', dialCode: '+90'),
  Country(name: 'Ukraine', code: 'UA', dialCode: '+380'),
  Country(name: 'United Arab Emirates', code: 'AE', dialCode: '+971'),
  Country(name: 'Vietnam', code: 'VN', dialCode: '+84'),
];

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

  Country _selectedCountry = _countries.first;
  String _lastSentPhone = '';

  bool _rememberMe = true;
  bool _otpSent = false;

  String? _phoneError;
  String? _otpError;

  @override
  void initState() {
    super.initState();
    _phoneFocus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _phoneFocus.removeListener(_onFocusChange);
    _phoneController.dispose();
    _otpController.dispose();
    _phoneFocus.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  String _getFullPhoneNumber() {
    String text = _phoneController.text.trim();
    text = text.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (text.startsWith('+')) {
      return text;
    }
    final dialDigits = _selectedCountry.dialCode.replaceFirst('+', '');
    if (text.startsWith(dialDigits) && text.length > dialDigits.length + 5) {
      return '+$text';
    }
    if (text.startsWith('0')) {
      text = text.substring(1);
    }
    return '${_selectedCountry.dialCode}$text';
  }

  String? _validatePhone(String value) {
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.isEmpty) return 'Phone number is required';
    if (cleaned.startsWith('+')) {
      if (cleaned.length < 8) return 'Enter a valid phone number';
      return null;
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(cleaned)) {
      return 'Enter valid digits only';
    }
    if (cleaned.length < 6) return 'Phone number is too short';
    if (cleaned.length > 15) return 'Phone number is too long';
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

    final fullPhone = _getFullPhoneNumber();
    _lastSentPhone = fullPhone;

    final success = await ref
        .read(authControllerProvider.notifier)
        .sendOtp(phone: fullPhone);

    if (!mounted) return;

    if (success) {
      setState(() => _otpSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP sent to $fullPhone. Please check your phone.'),
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
    final phone = _lastSentPhone.isNotEmpty ? _lastSentPhone : _getFullPhoneNumber();
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

  void _showTermsDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: GoogleFonts.archivoBlack(color: Colors.white, fontSize: 18),
        ),
        content: Text(
          'Please visit our website or contact support for full details regarding our $title.',
          style: GoogleFonts.barlow(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'OK',
              style: GoogleFonts.barlow(
                color: const Color(0xFFE85D04),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = true; // Always style as dark mode since the screen background is black
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.08),

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

                SizedBox(height: size.height * 0.07),

                if (!_otpSent) ...[
                  _buildPhoneField(isDark: isDark, screenWidth: size.width),
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
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.barlow(
                          fontSize: 12,
                          height: 1.45,
                          color: Colors.white.withOpacity(0.65),
                        ),
                        children: [
                          const TextSpan(text: 'By continuing, you agree to our '),
                          TextSpan(
                            text: 'Terms of Service',
                            style: GoogleFonts.barlow(
                              color: const Color(0xFFE85D04),
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: const Color(0xFFE85D04),
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => _showTermsDialog(context, 'Terms of Service'),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: GoogleFonts.barlow(
                              color: const Color(0xFFE85D04),
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: const Color(0xFFE85D04),
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => _showTermsDialog(context, 'Privacy Policy'),
                          ),
                          const TextSpan(
                            text:
                                '. You consent to receive SMS verification codes from ThePawffy. Message frequency varies. Message & data rates may apply.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  if (_lastSentPhone.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Enter the 6-digit code sent to $_lastSentPhone',
                        style: GoogleFonts.barlow(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
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

  Widget _buildPhoneField({required bool isDark, required double screenWidth}) {
    final fillColor = isDark ? const Color(0xFF232323) : const Color(0xFFF2F2F2);
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = Colors.grey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _phoneError != null
                  ? Colors.redAccent
                  : (_phoneFocus.hasFocus
                      ? const Color(0xFFE85D04)
                      : Colors.transparent),
              width: _phoneError != null ? 1.2 : 1.5,
            ),
          ),
          padding: const EdgeInsets.only(left: 12, right: 12),
          child: Row(
            children: [
              // Country Code Dropdown
              DropdownButtonHideUnderline(
                child: DropdownButton<Country>(
                  value: _selectedCountry,
                  dropdownColor: const Color(0xFF232323),
                  borderRadius: BorderRadius.circular(12),
                  menuMaxHeight: 350,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey,
                    size: 18,
                  ),
                  selectedItemBuilder: (BuildContext context) {
                    return _countries.map((Country country) {
                      return ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: screenWidth * 0.38),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${country.name} (${country.dialCode})',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: GoogleFonts.barlow(
                              color: textColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList();
                  },
                  items: _countries.map((Country country) {
                    return DropdownMenuItem<Country>(
                      value: country,
                      child: Text(
                        '${country.name} (${country.dialCode})',
                        style: GoogleFonts.barlow(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (Country? val) {
                    if (val != null) {
                      setState(() => _selectedCountry = val);
                    }
                  },
                ),
              ),
              Container(
                height: 24,
                width: 1,
                color: Colors.grey.withOpacity(0.3),
                margin: const EdgeInsets.symmetric(horizontal: 6),
              ),
              // Phone Input Field
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  focusNode: _phoneFocus,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  style: GoogleFonts.barlow(color: textColor, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Phone number',
                    hintStyle: GoogleFonts.barlow(
                      color: hintColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 16,
                    ),
                  ),
                  onChanged: (_) {
                    if (_phoneError != null) {
                      setState(() {
                        _phoneError = _validatePhone(_phoneController.text.trim());
                      });
                    }
                  },
                  onSubmitted: (_) => _handleSendOtp(),
                ),
              ),
            ],
          ),
        ),
        if (_phoneError != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              _phoneError!,
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
