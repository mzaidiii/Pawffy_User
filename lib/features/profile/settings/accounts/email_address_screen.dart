import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pawffy/features/auth/providers/current_user_provider.dart';
import '../support/help_contact_screen.dart';

import '../widgets/settings_appbar.dart';
import '../widgets/settings_button.dart';
import '../widgets/settings_header_icon.dart';

class EmailAddressScreen extends ConsumerWidget {
  const EmailAddressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.asData?.value;
    final controller = TextEditingController(text: user?.email ?? 'Loading...');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const SettingsAppBar(title: 'Email Address'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const SettingsHeaderIcon(icon: Icons.mail_outline),
            const SizedBox(height: 14),
            Text(
              'Your registered email address',
              textAlign: TextAlign.center,
              style: GoogleFonts.barlow(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Email Address',
                style: GoogleFonts.barlow(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: controller,
              readOnly: true,
              style: GoogleFonts.barlow(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
                  ),
                ),
                prefixIcon: const Icon(Icons.lock_outline, size: 18),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF2A1D0F)
                    : const Color(0xFFFFF9ED),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF3D2510)
                      : const Color(0xFFFFE8D6),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFFE85D04)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'For security and verification purposes, email addresses cannot be changed directly in the app. Please contact our support team to update your email.',
                      style: GoogleFonts.barlow(
                        fontSize: 13,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SettingsButton(
              text: 'CONTACT SUPPORT',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpContactScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
