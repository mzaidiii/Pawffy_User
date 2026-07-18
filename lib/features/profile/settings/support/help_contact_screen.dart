import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

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
      'subtitle': 'rescuepaws@gmail.com',
      'url': 'mailto:rescuepaws@gmail.com',
    },
    {
      'icon': Icons.call_outlined,
      'title': 'Call Us',
      'subtitle': '+1 (510) 520-7318',
      'url': 'tel:+15105207318',
    },
    {
      'icon': Icons.location_on_outlined,
      'title': 'Location',
      'subtitle': 'Houston, TX 77493, US',
      'url':
          'https://www.bing.com/maps/search?q=Houston%2C+TX+77493%2C+US&cp=29.817641%7E-95.462300&lvl=10.2&style=r',
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
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  Text(
                    'Contact Us',
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
                      onTap: () => _openContactLink(
                        context,
                        contact['url'] as String,
                      ),
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
              text: 'CREATE A TICKET',
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

  Future<void> _openContactLink(BuildContext context, String url) async {
    final opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open this link.')),
      );
    }
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
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
        ),
      ),
    );
  }
}
