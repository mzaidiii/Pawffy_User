import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/settings_appbar.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const SettingsAppBar(title: 'TERMS & CONDITIONS'),
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
                  Icons.description_outlined,
                  color: Color(0xFFE85D04),
                  size: 40,
                ),
              ),
            ),

            const SizedBox(height: 14),

            Center(
              child: Text(
                'Terms & Conditions',
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
                style: GoogleFonts.barlow(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ),

            const SizedBox(height: 28),

            _buildSection(
              context,
              'Welcome to PawCare!',
              'At PawCare, we value your privacy and are committed to protecting your personal information. This policy explains how we collect, use, and share your data when you use the PawCare application and our services provided by us.',
            ),

            _buildSection(
              context,
              '1. Acceptance of Terms',
              'By using PawCare, you agree to these Terms & Conditions. If you do not agree, please do not use the app.',
            ),

            _buildSection(
              context,
              '2. Use of Services',
              'PawCare provides a platform to connect pet parents with trusted service providers. You are responsible for the accuracy of the information you provide when making bookings.',
            ),

            _buildSection(
              context,
              '3. User Responsibilities',
              'You are responsible for maintaining the confidentiality of your account. You must not use the app for any unlawful purpose. Treat all service providers and partners required to fulfill your order with respect.',
            ),

            _buildSection(
              context,
              '4. Payments',
              'All payments are processed securely. Prices are subject to change without notice.',
            ),

            _buildSection(
              context,
              '5. Cancellations & Refunds',
              'Cancellations and refund eligibility are subject to our policy.',
            ),

            _buildSection(
              context,
              '6. Your Choices',
              'You can access, update, or delete your account information at any time through the app settings. You may also request deletion of your account.',
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF3E2D20)
                    : const Color(0xFFFFF9ED),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFFE85D04),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'By continuing to use Pawffy, you agree to these terms.',
                      style: GoogleFonts.barlow(
                        fontSize: 13,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.black87,
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

  Widget _buildSection(BuildContext context, String title, String body) {
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
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: GoogleFonts.barlow(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
