import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pawffy/main.dart';

import '../widgets/settings_appbar.dart';

class AppAppearanceScreen extends ConsumerWidget {
  const AppAppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      // Removed hardcoded background - now respects theme
      appBar: const SettingsAppBar(title: 'APP APPEARANCE'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            Center(
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF2A2A2A)
                      : const Color(0xFFFFF1E8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.dark_mode_outlined,
                  color: Color(0xFFE85D04),
                  size: 40,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Center(
              child: Text(
                'Choose Appearance',
                style: GoogleFonts.barlow(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Center(
              child: Text(
                'Select your preferred Theme',
                style: GoogleFonts.barlow(
                  fontSize: 13,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.black54,
                ),
              ),
            ),

            const SizedBox(height: 32),

            _buildThemeOption(
              context,
              ref,
              title: 'Light',
              subtitle: 'Light theme',
              icon: Icons.light_mode_outlined,
              isSelected: themeMode == ThemeMode.light,
              mode: ThemeMode.light,
            ),
            const SizedBox(height: 12),
            _buildThemeOption(
              context,
              ref,
              title: 'Dark',
              subtitle: 'Dark theme',
              icon: Icons.dark_mode_outlined,
              isSelected: themeMode == ThemeMode.dark,
              mode: ThemeMode.dark,
            ),
            const SizedBox(height: 12),
            _buildThemeOption(
              context,
              ref,
              title: 'System Default',
              subtitle: 'Use system settings',
              icon: Icons.settings_suggest_outlined,
              isSelected: themeMode == ThemeMode.system,
              mode: ThemeMode.system,
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFFFF9ED),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.wb_sunny_outlined, color: Color(0xFFE85D04)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Light theme is easier on eyes and works well in daylight.',
                      style: GoogleFonts.barlow(
                        fontSize: 13,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required ThemeMode mode,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        ref.read(themeModeProvider.notifier).state = mode;
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF232323) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFE85D04) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFFFF1E8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFFE85D04)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.barlow(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.barlow(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? const Color(0xFFE85D04) : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
