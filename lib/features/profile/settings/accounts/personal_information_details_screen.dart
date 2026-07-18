import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pawffy/core/utils/image_picker_helper.dart';
import 'package:pawffy/features/auth/data/models/user_model.dart';
import 'package:pawffy/features/auth/providers/current_user_provider.dart';

import '../widgets/settings_appbar.dart';

/// Read-only account information returned by the authenticated user API.
class PersonalInformationDetailsScreen extends ConsumerWidget {
  const PersonalInformationDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const SettingsAppBar(title: 'Personal Information'),
      body: userAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFE85D04)),
        ),
        error: (_, __) => const Center(
          child: Text('Unable to load personal information.'),
        ),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User information is unavailable.'));
          }

          return RefreshIndicator(
            color: const Color(0xFFE85D04),
            onRefresh: () => ref.read(currentUserProvider.notifier).refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              children: [
                _ProfileHeader(user: user),
                const SizedBox(height: 28),
                _InformationCard(
                  children: [
                    _InformationRow(
                      icon: Icons.person_outline,
                      label: 'Full Name',
                      value: user.name,
                    ),
                    _InformationRow(
                      icon: Icons.email_outlined,
                      label: 'Email Address',
                      value: user.email,
                    ),
                    _InformationRow(
                      icon: Icons.phone_outlined,
                      label: 'Phone Number',
                      value: user.phone,
                    ),
                    _InformationRow(
                      icon: Icons.home_outlined,
                      label: 'Address',
                      value: user.address,
                    ),
                    _InformationRow(
                      icon: Icons.location_city_outlined,
                      label: 'City',
                      value: user.city,
                    ),
                    _InformationRow(
                      icon: Icons.map_outlined,
                      label: 'State',
                      value: user.state,
                      showDivider: false,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final hasImage = user.profileImage?.isNotEmpty ?? false;

    return Column(
      children: [
        CircleAvatar(
          radius: 54,
          backgroundColor: const Color(0xFFF3E8E2),
          backgroundImage: hasImage
              ? ImagePickerHelper.getImageProvider(user.profileImage!)
              : null,
          child: hasImage
              ? null
              : const Icon(Icons.person_outline, size: 52, color: Color(0xFFE85D04)),
        ),
        const SizedBox(height: 14),
        Text(
          user.name.isEmpty ? 'Pet Parent' : user.name,
          style: GoogleFonts.barlow(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Your account information',
          style: GoogleFonts.barlow(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

class _InformationCard extends StatelessWidget {
  const _InformationCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(children: children),
    );
  }
}

class _InformationRow extends StatelessWidget {
  const _InformationRow({
    required this.icon,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final String? value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final displayValue = value?.trim().isNotEmpty == true ? value!.trim() : 'Not provided';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE85D04).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFFE85D04), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.barlow(
                        fontSize: 12,
                        color: textColor.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      displayValue,
                      style: GoogleFonts.barlow(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: value?.trim().isNotEmpty == true
                            ? textColor
                            : textColor.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, indent: 68, endIndent: 16),
      ],
    );
  }
}
