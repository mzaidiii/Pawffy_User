import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/settings_appbar.dart';
import 'terms_screen.dart';
import 'privacy_policy_screen.dart';

class AboutPawffyScreen extends StatelessWidget {
  const AboutPawffyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const SettingsAppBar(title: 'ABOUT PAWFFY'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Logo Placeholder
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFFE85D04).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.pets,
                  color: Color(0xFFE85D04),
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // App Name & Version
            Text(
              'Pawffy',
              style: GoogleFonts.barlow(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'Version 1.0.0',
              style: GoogleFonts.barlow(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),

            // Tagline
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF2A1F16)
                    : const Color(0xFFFFF1E8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "World's #1 Pet Care Platform",
                style: GoogleFonts.barlow(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE85D04),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // About text
            Text(
              "Pawffy connects pet owners with trusted vets, groomers, walkers, trainers, and more — all in one place. Book appointments, track your pet's health, and give them the care they deserve.",
              textAlign: TextAlign.center,
              style: GoogleFonts.barlow(
                fontSize: 14,
                height: 1.5,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 32),

            // Interactive list of links
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
                ),
              ),
              child: Column(
                children: [
                  _buildLinkTile(
                    context,
                    title: 'Terms of Service',
                    icon: Icons.description_outlined,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TermsScreen()),
                    ),
                  ),
                  _buildDivider(context),
                  _buildLinkTile(
                    context,
                    title: 'Privacy Policy',
                    icon: Icons.privacy_tip_outlined,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                    ),
                  ),
                  _buildDivider(context),
                  _buildLinkTile(
                    context,
                    title: 'Open Source Licenses',
                    icon: Icons.gavel_outlined,
                    onTap: () => showLicensePage(
                      context: context,
                      applicationName: 'Pawffy',
                      applicationVersion: '1.0.0',
                      applicationIcon: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Icon(
                          Icons.pets,
                          color: Theme.of(context).primaryColor,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Social Media section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Follow Us',
                style: GoogleFonts.barlow(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
                ),
              ),
              child: Column(
                children: [
                  _buildSocialRow(context, icon: Icons.camera_alt_outlined, name: 'Instagram', handle: '@pawffy'),
                  _buildDivider(context),
                  _buildSocialRow(context, icon: Icons.alternate_email_outlined, name: 'Twitter (X)', handle: '@pawffy'),
                  _buildDivider(context),
                  _buildSocialRow(context, icon: Icons.facebook_outlined, name: 'Facebook', handle: 'Pawffy India'),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Copyright notice
            Text(
              '© 2026 Pawffy. All rights reserved.',
              style: GoogleFonts.barlow(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: const Color(0xFFE85D04)),
      title: Text(
        title,
        style: GoogleFonts.barlow(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
    );
  }

  Widget _buildSocialRow(
    BuildContext context, {
    required IconData icon,
    required String name,
    required String handle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), size: 20),
          const SizedBox(width: 12),
          Text(
            name,
            style: GoogleFonts.barlow(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          Text(
            handle,
            style: GoogleFonts.barlow(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFE85D04),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
    );
  }
}
