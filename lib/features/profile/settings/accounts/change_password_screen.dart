import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/settings_appbar.dart';
import '../widgets/settings_button.dart';
import '../widgets/settings_header_icon.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final currentController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();

  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: const SettingsAppBar(title: 'Change Password'),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            const Center(child: SettingsHeaderIcon(icon: Icons.lock_outline)),

            const SizedBox(height: 12),

            Text(
              'Choose a strong password to\nkeep your account secure',
              textAlign: TextAlign.center,
              style: GoogleFonts.barlow(fontSize: 12, color: Colors.black54),
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

            _passwordField('New Password', newController, obscureNew, () {
              setState(() {
                obscureNew = !obscureNew;
              });
            }),

            const SizedBox(height: 10),

            const _RequirementTile('At least 8 Character'),
            const _RequirementTile('Include a number'),
            const _RequirementTile('Includes an Upper Case'),

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

            const Spacer(),

            SettingsButton(text: 'Update Password', onTap: () {}),
          ],
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
        Text(label, style: GoogleFonts.barlow(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            suffixIcon: IconButton(
              onPressed: onTap,
              icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}

class _RequirementTile extends StatelessWidget {
  final String text;

  const _RequirementTile(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Text(text, style: GoogleFonts.barlow(fontSize: 13)),
        ],
      ),
    );
  }
}
