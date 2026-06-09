import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/settings_appbar.dart';
import '../widgets/settings_button.dart';
import '../widgets/settings_header_icon.dart';

class EmailAddressScreen extends StatelessWidget {
  const EmailAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: 'avntika.sharma@gmail.com');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: const SettingsAppBar(title: 'Email Address'),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            const SettingsHeaderIcon(icon: Icons.mail_outline),

            const SizedBox(height: 14),

            Text(
              'Update your Email Address\nWe will send a verification link\nto your email address.',
              textAlign: TextAlign.center,
              style: GoogleFonts.barlow(fontSize: 12, color: Colors.black54),
            ),

            const SizedBox(height: 30),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Email Address',
                style: GoogleFonts.barlow(fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 6),

            TextField(
              controller: controller,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const Spacer(),

            SettingsButton(text: 'Send Verification', onTap: () {}),
          ],
        ),
      ),
    );
  }
}
