import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/settings_appbar.dart';
import '../widgets/settings_button.dart';
import '../widgets/settings_header_icon.dart';

class MobileOtpScreen extends StatelessWidget {
  const MobileOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

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
              style: GoogleFonts.barlow(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),

            const SizedBox(height: 30),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Enter OTP',
                style: GoogleFonts.barlow(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                6,
                (index) => Container(
                  width: 45,
                  height: 45,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF232323) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
                    ),
                  ),
                  child: Text(
                    'X',
                    style: GoogleFonts.barlow(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),

            SettingsButton(text: 'Send OTP', onTap: () {}),
          ],
        ),
      ),
    );
  }
}
