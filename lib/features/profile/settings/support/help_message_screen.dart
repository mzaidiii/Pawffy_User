import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/settings_appbar.dart';
import '../widgets/settings_button.dart';
import '../widgets/settings_header_icon.dart';
import 'support_service.dart';

class HelpMessageScreen extends ConsumerStatefulWidget {
  const HelpMessageScreen({super.key});

  @override
  ConsumerState<HelpMessageScreen> createState() => _HelpMessageScreenState();
}

class _HelpMessageScreenState extends ConsumerState<HelpMessageScreen> {
  final _messageController = TextEditingController();
  String? _selectedSubject;
  String? _attachedFileName;
  String? _attachedFilePath;
  bool _isLoading = false;

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

  Future<void> _handleAttachMockFile() async {
    try {
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/screenshot.png');
      await tempFile.writeAsBytes([0, 1, 2, 3]);
      setState(() {
        _attachedFilePath = tempFile.path;
        _attachedFileName = 'screenshot.png';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mock screenshot.png attached successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to attach file: $e')),
      );
    }
  }

  String _mapSubjectToCategory(String subject) {
    switch (subject) {
      case 'Booking Issue':
        return 'booking_issue';
      case 'Payment Problem':
        return 'payment_issue';
      case 'Account & Profile':
        return 'account_issue';
      case 'Technical Issue':
        return 'technical_issue';
      case 'Other':
      default:
        return 'general';
    }
  }

  Future<void> _handleSubmit() async {
    final subject = _selectedSubject;
    final message = _messageController.text.trim();

    if (subject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a subject')),
      );
      return;
    }
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your message')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(supportServiceProvider).createSupportTicket(
        subject: subject,
        category: _mapSubjectToCategory(subject),
        description: message,
        attachmentPath: _attachedFilePath,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Support ticket submitted successfully!',
            style: GoogleFonts.barlow(),
          ),
          backgroundColor: const Color(0xFF22C55E),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
            style: GoogleFonts.barlow(),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const SettingsAppBar(title: 'HELP & SUPPORT'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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

                        const SizedBox(height: 30),

                        // ── Dropdown Subject ──
                        Text(
                          'Subject',
                          style: GoogleFonts.barlow(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),

                        const SizedBox(height: 8),

                        DropdownButtonFormField<String>(
                          value: _selectedSubject,
                          style: GoogleFonts.barlow(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          dropdownColor: Theme.of(context).colorScheme.surface,
                          decoration: InputDecoration(
                            hintText: 'Select Subject',
                            hintStyle: GoogleFonts.barlow(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
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
                          items: _subjects.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() => _selectedSubject = newValue);
                          },
                        ),

                        const SizedBox(height: 20),

                        // ── Message Box ──
                        Text(
                          'Message',
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
                          onTap: _handleAttachMockFile,
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
                                    onTap: () {
                                      setState(() {
                                        _attachedFileName = null;
                                        _attachedFilePath = null;
                                      });
                                    },
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
                    onTap: _handleSubmit,
                  ),
                ),
              ],
            ),
    );
  }
}
