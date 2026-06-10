import 'package:flutter/material.dart';

import '../widgets/settings_appbar.dart';
import '../widgets/settings_button.dart';
import '../widgets/settings_header_icon.dart';

class MobileOtpScreen extends StatelessWidget {
  const MobileOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
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

            const Text(
              'Update your Mobile Number\nWe will send a verification code\nto your new number.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Enter OTP'),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('X'),
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
