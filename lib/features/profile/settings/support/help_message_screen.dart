import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/settings_appbar.dart';
import '../widgets/settings_button.dart';
import '../widgets/settings_header_icon.dart';

class HelpMessageScreen extends StatefulWidget {
  const HelpMessageScreen({super.key});

  @override
  State<HelpMessageScreen> createState() => _HelpMessageScreenState();
}

class _HelpMessageScreenState extends State<HelpMessageScreen> {
  final _messageController = TextEditingController();
  String? _selectedSubject;
  String? _attachedFileName;

  final List<String> _subjects = [
    'Booking Issue',
    'Payment Problem',
    'Account & Profile',
    'Technical Issue',
    'Other',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

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
                      'Send Us a Message',
                      style: GoogleFonts.barlow(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Center(
                    child: Text(
                      'We typically reply within 24 hours',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.barlow(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Subject Dropdown ──
                  Text(
                    'Subject',
                    style: GoogleFonts.barlow(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedSubject,
                        isExpanded: true,
                        hint: Text(
                          'Select a subject',
                          style: GoogleFonts.barlow(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        items: _subjects
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(
                                  s,
                                  style: GoogleFonts.barlow(fontSize: 14),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedSubject = val),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Message ──
                  Text(
                    'Your Message',
                    style: GoogleFonts.barlow(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: _messageController,
                    maxLines: 5,
                    style: GoogleFonts.barlow(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Write your message here',
                      hintStyle: GoogleFonts.barlow(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFE85D04),
                          width: 1.3,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Attach File ──
                  Text(
                    'Attach a file (Optional)',
                    style: GoogleFonts.barlow(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 8),

                  GestureDetector(
                    onTap: () {
                      // File picker integration later
                      setState(() => _attachedFileName = 'screenshot.png');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _attachedFileName != null
                              ? const Color(0xFFE85D04)
                              : const Color(0xFFE0E0E0),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _attachedFileName != null
                                ? Icons.attach_file_rounded
                                : Icons.add_rounded,
                            color: const Color(0xFFE85D04),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _attachedFileName ?? 'Add File',
                            style: GoogleFonts.barlow(
                              fontSize: 14,
                              color: _attachedFileName != null
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          if (_attachedFileName != null) ...[
                            const Spacer(),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _attachedFileName = null),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: SettingsButton(
              text: 'SEND MESSAGE',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Message sent! We\'ll reply within 24 hours.',
                      style: GoogleFonts.barlow(),
                    ),
                    backgroundColor: const Color(0xFF22C55E),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
