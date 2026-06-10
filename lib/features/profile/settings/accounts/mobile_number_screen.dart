import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/settings_appbar.dart';
import '../widgets/settings_button.dart';
import '../widgets/settings_header_icon.dart';
import 'mobile_otp_screen.dart';

class MobileNumberScreen extends StatelessWidget {
  const MobileNumberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: '+91 9462783945');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: const SettingsAppBar(title: 'Mobile Number'),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            const SettingsHeaderIcon(icon: Icons.smartphone_outlined),

            const SizedBox(height: 14),

            Text(
              'Update your Mobile Number\nWe will send a verification code\nto your new number.',
              textAlign: TextAlign.center,
              style: GoogleFonts.barlow(fontSize: 12, color: Colors.black54),
            ),

            const SizedBox(height: 30),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Mobile Number',
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

            SettingsButton(
              text: 'Send OTP',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MobileOtpScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
