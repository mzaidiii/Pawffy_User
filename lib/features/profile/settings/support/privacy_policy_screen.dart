import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/settings_appbar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const SettingsAppBar(title: 'PRIVACY POLICY'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // ── Header ──
            Center(
              child: Container(
                width: 84,
                height: 84,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF1E8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.privacy_tip_outlined,
                  color: Color(0xFFE85D04),
                  size: 40,
                ),
              ),
            ),

            const SizedBox(height: 14),

            Center(
              child: Text(
                'Privacy Policy',
                style: GoogleFonts.barlow(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 4),

            Center(
              child: Text(
                'Last updated: 15 May 2026',
                style: GoogleFonts.barlow(fontSize: 12, color: Colors.black45),
              ),
            ),

            const SizedBox(height: 28),

            _buildSection(
              '1. Information We Collect',
              'We collect information you provide directly such as name, email, phone number, and address. We also collect usage data, device identifiers, and location information when you use our services.',
            ),

            _buildSection(
              '2. How We Use Information',
              'We use your information to provide and improve our services, personalize your experience, process bookings and payments, and send service notifications.',
            ),

            _buildSection(
              '3. Information Sharing',
              'We do not sell your personal information. We may share it with trusted service providers and partners required to fulfill your orders.',
            ),

            _buildSection(
              '4. Data Security',
              'We implement industry-standard security measures to protect your information from unauthorized access.',
            ),

            _buildSection(
              '5. Your Choices',
              'You can access, update, or delete your account information at any time through the app settings. You may also request deletion of your account.',
            ),

            _buildSection(
              '6. Cookies & Tracking',
              'We use cookies and similar technologies to enhance your experience and collect usage analytics. You can manage cookie preferences through your device settings.',
            ),

            _buildSection(
              '7. Children\'s Privacy',
              'Our services are not directed to children under 13. We do not knowingly collect personal information from children.',
            ),

            _buildSection(
              '8. Changes to Policy',
              'We may update this Privacy Policy periodically. We will notify you of significant changes via the app or email.',
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lock_outline,
                    color: Color(0xFF22C55E),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your data is encrypted and never sold to third parties.',
                      style: GoogleFonts.barlow(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.barlow(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: GoogleFonts.barlow(
              fontSize: 13,
              color: Colors.black54,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
