import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/settings_appbar.dart';
import '../widgets/settings_button.dart';
import '../widgets/settings_header_icon.dart';
import 'help_message_screen.dart';

class HelpContactScreen extends StatelessWidget {
  const HelpContactScreen({super.key});

  static const _contacts = [
    {
      'icon': Icons.email_outlined,
      'title': 'Email Us',
      'subtitle': 'support@pawffy.com',
    },
    {
      'icon': Icons.call_outlined,
      'title': 'Call Us',
      'subtitle': '+1 800 PAWFFY',
    },
    {
      'icon': Icons.chat_outlined,
      'title': 'WhatsApp Us',
      'subtitle': 'Chat with us on WhatsApp',
    },
    {
      'icon': Icons.language_outlined,
      'title': 'Visit Website',
      'subtitle': 'www.pawffy.com',
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
                      'We would like to hear from you!',
                      style: GoogleFonts.barlow(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Center(
                    child: Text(
                      'Send Us a Message\nWe typically reply within 24 hours',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.barlow(
                        fontSize: 13,
                        color: Colors.black54,
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

                  ..._contacts.map(
                    (contact) => _ContactTile(
                      icon: contact['icon'] as IconData,
                      title: contact['title'] as String,
                      subtitle: contact['subtitle'] as String,
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
                  MaterialPageRoute(builder: (_) => const HelpMessageScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ContactTile({
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
        color: Colors.white,
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
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.barlow(
                    fontSize: 12,
                    color: Colors.black54,
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
