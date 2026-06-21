import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/settings_appbar.dart';
import '../widgets/settings_button.dart';
import '../widgets/settings_header_icon.dart';
import 'help_contact_screen.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  String? _selectedCategory;

  static const _topics = [
    {
      'icon': Icons.calendar_today_outlined,
      'title': 'Bookings & Services',
      'subtitle': 'Help with booking and services',
      'category': 'bookings',
    },
    {
      'icon': Icons.manage_accounts_outlined,
      'title': 'Account and Profile',
      'subtitle': 'Account settings and profile',
      'category': 'account',
    },
    {
      'icon': Icons.payment_outlined,
      'title': 'Payment & Refunds',
      'subtitle': 'Payment issues, Bookings and History',
      'category': 'payment',
    },
    {
      'icon': Icons.build_outlined,
      'title': 'Technical Issues',
      'subtitle': 'Report a bug or technical problem',
      'category': 'technical',
    },
  ];

  static const _faqs = [
    {
      'question': 'How do I book a vet consultation?',
      'answer': 'Go to the Home tab, select "Vets", choose your preferred vet, pick an available slot, and confirm the booking after payment.',
      'category': 'bookings',
    },
    {
      'question': 'Can I change my appointment slot?',
      'answer': 'Yes, you can reschedule your booking from the Bookings screen up to 2 hours before the start time.',
      'category': 'bookings',
    },
    {
      'question': 'How can I add records for my pet?',
      'answer': 'Go to your Profile tab, select your pet, go to "Medical Records" or "Vaccinations", and click the add button at the bottom.',
      'category': 'account',
    },
    {
      'question': 'How do I change my mobile number?',
      'answer': 'Go to Settings -> Mobile Number, enter your new number, and click Update.',
      'category': 'account',
    },
    {
      'question': 'Can I cancel my booking and get a refund?',
      'answer': 'Yes, cancellations made up to 2 hours before the appointment are eligible for a full refund back to your Pawffy wallet.',
      'category': 'payment',
    },
    {
      'question': 'Is my payment secure?',
      'answer': 'Absolutely. We process payments securely via industry-standard encryption, and card data is never stored on our servers.',
      'category': 'payment',
    },
    {
      'question': 'The app is running slow, what should I do?',
      'answer': 'Try clearing the app cache, checking your internet connection, or restarting the application. If issues persist, contact support.',
      'category': 'technical',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredFaqs = _selectedCategory == null
        ? _faqs
        : _faqs.where((faq) => faq['category'] == _selectedCategory).toList();

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
                        color: Theme.of(context).colorScheme.onSurface,
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
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Help Topics Section ──
                  Text(
                    'Help Topics',
                    style: GoogleFonts.barlow(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._topics.map(
                    (topic) {
                      final category = topic['category'] as String;
                      final isSelected = _selectedCategory == category;
                      return _HelpTopicTile(
                        icon: topic['icon'] as IconData,
                        title: topic['title'] as String,
                        subtitle: topic['subtitle'] as String,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            if (_selectedCategory == category) {
                              _selectedCategory = null;
                            } else {
                              _selectedCategory = category;
                            }
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  // ── FAQ Section ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedCategory == null ? 'Frequently Asked Questions' : 'FAQs for Selected Topic',
                        style: GoogleFonts.barlow(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      if (_selectedCategory != null)
                        GestureDetector(
                          onTap: () => setState(() => _selectedCategory = null),
                          child: Text(
                            'Show All',
                            style: GoogleFonts.barlow(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFE85D04),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (filteredFaqs.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'No questions found in this category.',
                          style: GoogleFonts.barlow(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ),
                    )
                  else
                    ...filteredFaqs.map(
                      (faq) => _FAQTile(
                        key: ValueKey(faq['question']),
                        question: faq['question']!,
                        answer: faq['answer']!,
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

class _FAQTile extends StatefulWidget {
  final String question;
  final String answer;

  const _FAQTile({super.key, required this.question, required this.answer});

  @override
  State<_FAQTile> createState() => _FAQTileState();
}

class _FAQTileState extends State<_FAQTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            title: Text(
              widget.question,
              style: GoogleFonts.barlow(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            trailing: Icon(
              _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
              color: Colors.grey,
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.answer,
                style: GoogleFonts.barlow(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  height: 1.5,
                ),
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
  final bool isSelected;
  final VoidCallback onTap;

  const _HelpTopicTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE85D04).withOpacity(0.08)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFE85D04)
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFE85D04).withOpacity(0.2)
                    : const Color(0xFFE85D04).withOpacity(0.12),
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
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isSelected ? const Color(0xFFE85D04) : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
