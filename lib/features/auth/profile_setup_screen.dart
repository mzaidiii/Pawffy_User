import 'package:pawffy/features/auth/providers/auth_controller.dart';
import 'package:pawffy/features/home/home_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _addressController = TextEditingController();

  final _phoneFocus = FocusNode();
  final _cityFocus = FocusNode();
  final _stateFocus = FocusNode();
  final _addressFocus = FocusNode();



  String? _phoneError;
  String? _cityError;
  String? _stateError;
  String? _addressError;

  @override
  void dispose() {
    _phoneController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _addressController.dispose();
    _phoneFocus.dispose();
    _cityFocus.dispose();
    _stateFocus.dispose();
    _addressFocus.dispose();
    super.dispose();
  }

  String? _validatePhone(String value) {
    if (value.isEmpty) return 'Phone number is required';
    final digits = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!RegExp(r'^1?\d{10}$').hasMatch(digits)) {
      return 'Enter a valid US phone number (e.g. 555-867-5309)';
    }
    return null;
  }

  String? _validateCity(String value) {
    if (value.isEmpty) return 'City is required';
    if (value.trim().length < 2) return 'Enter a valid city name';
    if (!RegExp(r"^[a-zA-Z\s\.\-']{2,50}$").hasMatch(value.trim())) {
      return 'City name contains invalid characters';
    }
    return null;
  }

  String? _validateState(String value) {
    if (value.isEmpty) return 'State is required';
    final trimmed = value.trim();
    if (trimmed.length < 2) return 'Enter a valid US state';
    if (!RegExp(r"^[a-zA-Z\s]{2,50}$").hasMatch(trimmed)) {
      return 'Enter a valid US state name or abbreviation';
    }
    return null;
  }

  String? _validateAddress(String value) {
    if (value.isEmpty) return 'Address is required';
    if (value.trim().length < 5) return 'Enter a valid address';
    return null;
  }

  bool _validateAll() {
    final phoneErr = _validatePhone(_phoneController.text.trim());
    final cityErr = _validateCity(_cityController.text.trim());
    final stateErr = _validateState(_stateController.text.trim());
    final addressErr = _validateAddress(_addressController.text.trim());
    setState(() {
      _phoneError = phoneErr;
      _cityError = cityErr;
      _stateError = stateErr;
      _addressError = addressErr;
    });
    return phoneErr == null &&
        cityErr == null &&
        stateErr == null &&
        addressErr == null;
  }

  Future<void> _handleSubmit() async {
    if (!_validateAll()) return;

    final phone = _phoneController.text.trim();
    final city = _cityController.text.trim();
    final userState = _stateController.text.trim();
    final address = _addressController.text.trim();
    try {
      final profileSuccess = await ref
          .read(authControllerProvider.notifier)
          .updateProfile(
            phone: phone,
            city: city,
            userState: userState,
            address: address,
          );

      if (!mounted) return;
      if (!profileSuccess) {
        final error = ref.read(authControllerProvider);
        debugPrint('[ProfileSetup] updateProfile error: ${error.error}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
        return;
      }
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      debugPrint('[ProfileSetup] Exception caught: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark =
        true; // Always style as dark mode since the screen background is black
    final scaffoldBg = Colors.black;
    final authState = ref.watch(authControllerProvider);

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
                child: Icon(Icons.arrow_back, color: Colors.white, size: 24),
              ),

              SizedBox(height: size.height * 0.04),

              Text(
                'TELL US',
                style: GoogleFonts.archivoBlack(
                  fontSize: 52,
                  fontWeight: FontWeight.w400,
                  height: 0.95,
                  color: Colors.white,
                ),
              ),
              Text(
                'ABOUT YOU',
                style: GoogleFonts.archivoBlack(
                  fontSize: 48,
                  fontWeight: FontWeight.w400,
                  height: 0.95,
                  color: const Color(0xFFE85D04),
                ),
              ),
              const SizedBox(height: 10),

              Text(
                'Complete your profile',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFE0E0E0),
                ),
              ),

              SizedBox(height: size.height * 0.02),

              const SizedBox(height: 28),

              _buildTextField(
                controller: _phoneController,
                focusNode: _phoneFocus,
                hint: 'Phone Number',
                icon: Icons.phone_outlined,
                errorText: _phoneError,
                keyboardType: TextInputType.phone,
                isDark: isDark,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d\s\-\(\)]')),
                  LengthLimitingTextInputFormatter(14),
                ],
                onChanged: (_) {
                  if (_phoneError != null) {
                    setState(
                      () => _phoneError = _validatePhone(
                        _phoneController.text.trim(),
                      ),
                    );
                  }
                },
                onSubmitted: (_) => _cityFocus.requestFocus(),
              ),
              const SizedBox(height: 14),

              _buildTextField(
                controller: _cityController,
                focusNode: _cityFocus,
                hint: 'City',
                icon: Icons.location_city_outlined,
                errorText: _cityError,
                keyboardType: TextInputType.text,
                isDark: isDark,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) {
                  if (_cityError != null) {
                    setState(
                      () => _cityError = _validateCity(
                        _cityController.text.trim(),
                      ),
                    );
                  }
                },
                onSubmitted: (_) => _stateFocus.requestFocus(),
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _stateController,
                focusNode: _stateFocus,
                hint: 'State (e.g. California or CA)',
                icon: Icons.map_outlined,
                errorText: _stateError,
                keyboardType: TextInputType.text,
                isDark: isDark,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) {
                  if (_stateError != null) {
                    setState(
                      () => _stateError = _validateState(
                        _stateController.text.trim(),
                      ),
                    );
                  }
                },
                onSubmitted: (_) => _addressFocus.requestFocus(),
              ),

              const SizedBox(height: 14),

              _buildTextField(
                controller: _addressController,
                focusNode: _addressFocus,
                hint: 'Street Address',
                icon: Icons.home_outlined,
                errorText: _addressError,
                keyboardType: TextInputType.streetAddress,
                isDark: isDark,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (_) {
                  if (_addressError != null) {
                    setState(
                      () => _addressError = _validateAddress(
                        _addressController.text.trim(),
                      ),
                    );
                  }
                },
                onSubmitted: (_) => _handleSubmit(),
              ),

              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: authState.isLoading
                    ? null
                    : _handleSubmit,
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
                            'Complete Profile',
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

              const SizedBox(height: 30),
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
    List<TextInputFormatter>? inputFormatters,
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
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          textInputAction: TextInputAction.next,
          inputFormatters: inputFormatters,
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
