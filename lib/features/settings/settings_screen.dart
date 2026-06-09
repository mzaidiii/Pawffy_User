import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pawffy/features/settings/accounts/change_password_screen.dart';
import 'package:pawffy/features/settings/accounts/email_address_screen.dart';
import 'package:pawffy/features/settings/accounts/mobile_number_screen.dart';
import 'package:pawffy/features/settings/accounts/personal_information_screen.dart';
import 'package:pawffy/features/settings/preferences/app_appearance_screen.dart';
import 'package:pawffy/features/settings/preferences/language_screen.dart';
import 'package:pawffy/features/settings/preferences/location_settings_screen.dart';
import 'package:pawffy/features/settings/support/help_support_screen.dart';
import 'package:pawffy/features/settings/support/privacy_policy_screen.dart';
import 'package:pawffy/features/settings/support/terms_screen.dart';

import 'widgets/settings_tile.dart';
import 'widgets/settings_section_title.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'SETTINGS',
          style: GoogleFonts.barlow(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.black,
            letterSpacing: 1,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ───────────────── Profile Card ─────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color(0xFFF3E8E2),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFFE85D04),
                          size: 28,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE85D04),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Andrew Stevens',
                          style: GoogleFonts.barlow(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          'andrew@email.com',
                          style: GoogleFonts.barlow(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        Text(
                          '+1 234 567 8910',
                          style: GoogleFonts.barlow(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE85D04).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: Color(0xFFE85D04),
                    ),
                  ),
                ],
              ),
            ),

            // ───────────────── Accounts ─────────────────
            const SettingsSectionTitle(title: 'Accounts'),

            SettingsTile(
              icon: Icons.person_outline,
              title: 'Personal Information',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => PersonalInformationScreen(),
                  ),
                );
              },
            ),

            SettingsTile(
              icon: Icons.lock_outline,
              title: 'Change Password',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (ctx) => ChangePasswordScreen()),
                );
              },
            ),

            SettingsTile(
              icon: Icons.phone_android_outlined,
              title: 'Mobile Number',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (ctx) => MobileNumberScreen()),
                );
              },
            ),

            SettingsTile(
              icon: Icons.email_outlined,
              title: 'Email Address',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (ctx) => EmailAddressScreen()),
                );
              },
            ),

            // ───────────────── Preferences ─────────────────
            const SettingsSectionTitle(title: 'Preferences'),

            SettingsTile(
              icon: Icons.notifications_none,
              title: 'Notifications',
              onTap: () {},
            ),

            SettingsTile(
              icon: Icons.language,
              title: 'Language',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (ctx) => LanguageScreen()),
                );
              },
            ),

            SettingsTile(
              icon: Icons.dark_mode_outlined,
              title: 'App Appearance',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (ctx) => AppAppearanceScreen()),
                );
              },
            ),

            SettingsTile(
              icon: Icons.location_on_outlined,
              title: 'Location',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (ctx) => LocationSettingsScreen()),
                );
              },
            ),

            // ───────────────── Support ─────────────────
            const SettingsSectionTitle(title: 'Support & More'),

            SettingsTile(
              icon: Icons.headset_mic_outlined,
              title: 'Help & Support',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                );
              },
            ),

            SettingsTile(
              icon: Icons.description_outlined,
              title: 'Terms & Conditions',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TermsScreen()),
                );
              },
            ),

            SettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyScreen(),
                  ),
                );
              },
            ),

            SettingsTile(
              icon: Icons.info_outline,
              title: 'About Pawffy',
              onTap: () {},
            ),

            const SizedBox(height: 20),

            // ───────────────── Logout ─────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.logout, color: Colors.red),
                label: Text(
                  'LOG OUT',
                  style: GoogleFonts.barlow(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
