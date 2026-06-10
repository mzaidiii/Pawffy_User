import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/settings_appbar.dart';
import '../widgets/settings_button.dart';
import '../widgets/settings_header_icon.dart';
import 'help_contact_screen.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const _topics = [
    {
      'icon': Icons.quiz_outlined,
      'title': 'Frequently Asked Questions',
      'subtitle': 'Find quick answers here',
    },
    {
      'icon': Icons.calendar_today_outlined,
      'title': 'Bookings & Services',
      'subtitle': 'Help with booking and services',
    },
    {
      'icon': Icons.manage_accounts_outlined,
      'title': 'Account and Profile',
      'subtitle': 'Account settings and profile',
    },
    {
      'icon': Icons.payment_outlined,
      'title': 'Payment & Refunds',
      'subtitle': 'Payment issues, Bookings and History',
    },
    {
      'icon': Icons.build_outlined,
      'title': 'Technical Issues',
      'subtitle': 'Report a bug or technical problem',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const SettingsAppBar(title: 'HELP & SUPPORT'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  const Center(
                    child: SettingsHeaderIcon(icon: Icons.headset_mic_outlined),
                  ),

                  const SizedBox(height: 14),

                  Center(
                    child: Text(
                      'How can we help you?',
                      style: GoogleFonts.barlow(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Center(
                    child: Text(
                      'Choose a topic or contact us and\nwe will get back to you',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.barlow(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  Text(
                    'Help Topics',
                    style: GoogleFonts.barlow(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 12),

                  ..._topics.map(
                    (topic) => _HelpTopicTile(
                      icon: topic['icon'] as IconData,
                      title: topic['title'] as String,
                      subtitle: topic['subtitle'] as String,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: SettingsButton(
              text: 'CONTACT SUPPORT',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpContactScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpTopicTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _HelpTopicTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE85D04).withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFFE85D04), size: 18),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.barlow(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.barlow(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}
