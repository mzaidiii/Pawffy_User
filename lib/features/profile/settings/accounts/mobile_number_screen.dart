import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pawffy/features/auth/providers/current_user_provider.dart';
import 'package:pawffy/features/auth/providers/auth_controller.dart';
import 'package:pawffy/features/auth/data/models/user_model.dart';

import '../widgets/settings_appbar.dart';
import '../widgets/settings_button.dart';
import '../widgets/settings_header_icon.dart';

class MobileNumberScreen extends ConsumerStatefulWidget {
  const MobileNumberScreen({super.key});

  @override
  ConsumerState<MobileNumberScreen> createState() => _MobileNumberScreenState();
}

class _MobileNumberScreenState extends ConsumerState<MobileNumberScreen> {
  late final TextEditingController _phoneController;
  bool _isInitialized = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _initializeFields(UserModel user) {
    if (_isInitialized) return;
    _phoneController.text = user.phone ?? '';
    _isInitialized = true;
  }

  Future<void> _updatePhone(UserModel user) async {
    final newPhone = _phoneController.text.trim();
    if (newPhone.isEmpty) {
      _showSnackbar('Mobile number cannot be empty', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final success = await ref
        .read(authControllerProvider.notifier)
        .updateProfile(
          name: user.name,
          phone: newPhone,
          city: user.city ?? '',
          userState: user.state ?? '',
          address: user.address ?? '',
        );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        _showSnackbar('Mobile number updated successfully!', isError: false);
        Navigator.pop(context);
      } else {
        _showSnackbar('Failed to update mobile number', isError: true);
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
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator(color: Color(0xFFE85D04))),
      ),
      error: (_, __) => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: Text('Error loading profile')),
      ),
      data: (user) {
        if (user == null) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: const Center(child: Text('User not found')),
          );
        }

        _initializeFields(user);

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: const SettingsAppBar(title: 'Mobile Number'),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Center(child: SettingsHeaderIcon(icon: Icons.smartphone_outlined)),
                const SizedBox(height: 14),
                Center(
                  child: Text(
                    'Update your Mobile Number\nKeep your contact information\naccurate and up to date.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.barlow(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'Mobile Number',
                  style: GoogleFonts.barlow(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.barlow(color: Theme.of(context).colorScheme.onSurface),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
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
                const SizedBox(height: 80),
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Color(0xFFE85D04)),
                      )
                    : SettingsButton(
                        text: 'Update Mobile Number',
                        onTap: () => _updatePhone(user),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}
