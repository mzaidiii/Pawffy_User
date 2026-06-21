import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pawffy/features/auth/providers/auth_controller.dart';
import '../widgets/settings_appbar.dart';
import '../widgets/settings_button.dart';
import '../widgets/settings_header_icon.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final currentController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();

  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;
  bool _isLoading = false;

  String _newPassword = '';

  @override
  void initState() {
    super.initState();
    newController.addListener(() {
      setState(() {
        _newPassword = newController.text;
      });
    });
  }

  @override
  void dispose() {
    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  bool get _hasEightChars => _newPassword.length >= 8;
  bool get _hasUppercase => _newPassword.contains(RegExp(r'[A-Z]'));
  bool get _hasNumber => _newPassword.contains(RegExp(r'[0-9]'));
  bool get _hasSpecialChar => _newPassword.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  Future<void> _updatePassword() async {
    if (currentController.text.isEmpty) {
      _showSnackbar('Current password is required', isError: true);
      return;
    }
    if (!_hasEightChars || !_hasUppercase || !_hasNumber || !_hasSpecialChar) {
      _showSnackbar('Password does not meet requirements', isError: true);
      return;
    }
    if (newController.text != confirmController.text) {
      _showSnackbar('Confirm password does not match', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final success = await ref.read(authControllerProvider.notifier).changePassword(
          currentPassword: currentController.text,
          newPassword: newController.text,
        );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        _showSnackbar('Password changed successfully!', isError: false);
        Navigator.pop(context);
      } else {
        _showSnackbar('Current password is incorrect or failed to change', isError: true);
      }
    }
  }

  void _showSnackbar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.barlow(),
        ),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const SettingsAppBar(title: 'Change Password'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Center(child: SettingsHeaderIcon(icon: Icons.lock_outline)),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Choose a strong password to\nkeep your account secure',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.barlow(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _passwordField(
                'Current Password',
                currentController,
                obscureCurrent,
                () {
                  setState(() {
                    obscureCurrent = !obscureCurrent;
                  });
                },
              ),
              const SizedBox(height: 14),
              _passwordField(
                'New Password',
                newController,
                obscureNew,
                () {
                  setState(() {
                    obscureNew = !obscureNew;
                  });
                },
              ),
              const SizedBox(height: 12),
              _RequirementTile(
                text: 'At least 8 Characters',
                isMet: _hasEightChars,
              ),
              _RequirementTile(
                text: 'Include a number',
                isMet: _hasNumber,
              ),
              _RequirementTile(
                text: 'Includes an Upper Case letter',
                isMet: _hasUppercase,
              ),
              _RequirementTile(
                text: 'Includes a special character (!@#\$%^&*)',
                isMet: _hasSpecialChar,
              ),
              const SizedBox(height: 14),
              _passwordField(
                'Confirm Password',
                confirmController,
                obscureConfirm,
                () {
                  setState(() {
                    obscureConfirm = !obscureConfirm;
                  });
                },
              ),
              const SizedBox(height: 40),
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFFE85D04)),
                    )
                  : SettingsButton(
                      text: 'Update Password',
                      onTap: _updatePassword,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _passwordField(
    String label,
    TextEditingController controller,
    bool obscure,
    VoidCallback onTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.barlow(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: GoogleFonts.barlow(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            suffixIcon: IconButton(
              onPressed: onTap,
              icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _RequirementTile extends StatelessWidget {
  final String text;
  final bool isMet;

  const _RequirementTile({
    required this.text,
    required this.isMet,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isMet ? Colors.green : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.barlow(
              fontSize: 13,
              color: isMet
                  ? Colors.green
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
