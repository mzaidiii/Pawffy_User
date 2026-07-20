import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pawffy/core/utils/image_picker_helper.dart';

import 'package:pawffy/features/profile/settings/support/help_support_screen.dart';
import 'package:pawffy/features/profile/settings/support/terms_screen.dart';
import 'package:pawffy/features/profile/settings/support/privacy_policy_screen.dart';
import 'package:pawffy/features/profile/settings/support/about_pawffy_screen.dart';
import 'package:pawffy/features/profile/settings/support/delete_account_screen.dart';
import 'accounts/email_address_screen.dart';
import 'accounts/mobile_number_screen.dart';
import 'accounts/personal_information_screen.dart';
import 'accounts/personal_information_details_screen.dart';

import 'preferences/app_appearance_screen.dart';
import 'preferences/location_settings_screen.dart';

import 'widgets/settings_tile.dart';
import 'widgets/settings_section_title.dart';

import 'package:pawffy/features/auth/providers/current_user_provider.dart';
import 'package:pawffy/features/auth/providers/auth_controller.dart';
import 'package:pawffy/features/auth/onboardingScreen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.asData?.value;

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
            color: Theme.of(context).colorScheme.onSurface,
            letterSpacing: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: isDark
                            ? const Color(0xFF3A2A2A)
                            : const Color(0xFFF3E8E2),
                        backgroundImage: user?.profileImage != null &&
                                user!.profileImage!.isNotEmpty
                            ? ImagePickerHelper.getImageProvider(user.profileImage!)
                            : null,
                        child: user?.profileImage == null ||
                                user!.profileImage!.isEmpty
                            ? const Icon(
                                Icons.person,
                                color: Color(0xFFE85D04),
                                size: 28,
                              )
                            : null,
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
                            border: Border.all(
                              color: Theme.of(context).cardColor,
                              width: 2,
                            ),
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
                          user?.name ?? 'Loading...',
                          style: GoogleFonts.barlow(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? '',
                          style: GoogleFonts.barlow(
                            fontSize: 12,
                            color: isDark
                                ? Colors.white70
                                : Colors.grey.shade600,
                          ),
                        ),
                        if (user?.phone != null && user!.phone!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            user.phone!,
                            style: GoogleFonts.barlow(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white70
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PersonalInformationScreen(),
                      ),
                    ),
                    child: Container(
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
                  ),
                ],
              ),
            ),

            const SettingsSectionTitle(title: 'Accounts'),

            SettingsTile(
              icon: Icons.person_outline,
              title: 'Personal Information',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PersonalInformationDetailsScreen(),
                ),
              ),
            ),
            SettingsTile(
              icon: Icons.phone_android_outlined,
              title: 'Mobile Number',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MobileNumberScreen()),
              ),
            ),
            SettingsTile(
              icon: Icons.email_outlined,
              title: 'Email Address',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EmailAddressScreen()),
              ),
            ),

            const SettingsSectionTitle(title: 'Preferences'),

            SettingsTile(
              icon: Icons.dark_mode_outlined,
              title: 'App Appearance',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AppAppearanceScreen()),
              ),
            ),
            SettingsTile(
              icon: Icons.location_on_outlined,
              title: 'Location',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LocationSettingsScreen(),
                ),
              ),
            ),

            const SettingsSectionTitle(title: 'Support & More'),

            SettingsTile(
              icon: Icons.headset_mic_outlined,
              title: 'Help & Support',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (ctx) => HelpSupportScreen()),
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
                  MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                );
              },
            ),
            SettingsTile(
              icon: Icons.info_outline,
              title: 'About Pawffy',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutPawffyScreen()),
                );
              },
            ),
            SettingsTile(
              icon: Icons.delete_outline_rounded,
              title: 'Delete Account',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DeleteAccountScreen()),
              ),
            ),

            const SizedBox(height: 20),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Log Out?'),
                      content: const Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Log Out'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && context.mounted) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (ctx) => const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFE85D04),
                        ),
                      ),
                    );

                    await ref.read(authControllerProvider.notifier).logout();

                    if (context.mounted) {
                      // Close loading dialog
                      Navigator.pop(context); 
                      // Redirect to Onboarding
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                        (route) => false,
                      );
                    }
                  }
                },
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
