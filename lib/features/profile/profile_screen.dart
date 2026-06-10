import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pawffy/features/profile/address/address_screen.dart';
import 'package:pawffy/features/profile/settings/settings_screen.dart';
import 'package:pawffy/features/profile/settings/support/help_support_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'MY PROFILE',
                      style: GoogleFonts.barlow(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.onSurface,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SettingsScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.07),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.settings_outlined,
                              color: Theme.of(context).colorScheme.onSurface,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        Stack(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.07),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.notifications_outlined,
                                color: Theme.of(context).colorScheme.onSurface,
                                size: 20,
                              ),
                            ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                width: 9,
                                height: 9,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE85D04),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Profile Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? const Color(0xFF3A3A3A)
                                : const Color(0xFFE0E0E0),
                            border: Border.all(
                              color: const Color(0xFFE85D04),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            color: Colors.grey,
                            size: 36,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE85D04),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Amit Patel',
                                style: GoogleFonts.barlow(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFE85D04,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(
                                        0xFFE85D04,
                                      ).withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.edit_outlined,
                                        size: 12,
                                        color: Color(0xFFE85D04),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Edit Profile',
                                        style: GoogleFonts.barlow(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFFE85D04),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'amit.patel@gmail.com',
                            style: GoogleFonts.barlow(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF888888),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '+1 234 567 8900',
                            style: GoogleFonts.barlow(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF888888),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 13,
                                color: Color(0xFF888888),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'New York, USA',
                                style: GoogleFonts.barlow(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.white70
                                      : const Color(0xFF888888),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // My Pets
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'My Pets',
                  style: GoogleFonts.barlow(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 130,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 110,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF444444)
                                : const Color(0xFFDDDDDD),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE85D04).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                color: Color(0xFFE85D04),
                                size: 22,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add your\nPet',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.barlow(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white70
                                    : const Color(0xFF888888),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Menu Items
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
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
                  child: Column(
                    children: [
                      _buildMenuItem(
                        context,
                        icon: Icons.calendar_today_outlined,
                        title: 'My Bookings',
                        subtitle: 'View your upcoming and past bookings',
                        showDivider: true,
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.credit_card_outlined,
                        title: 'Payments and Wallets',
                        subtitle: 'Manage payments and refunds',
                        showDivider: true,
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.location_on_outlined,
                        title: 'Addresses',
                        subtitle: 'Manage your saved addresses',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddressScreen(),
                            ),
                          );
                        },
                        showDivider: true,
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.settings_outlined,
                        title: 'Settings',
                        subtitle: 'Notification, Privacy and more',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          );
                        },
                        showDivider: true,
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.headset_mic_outlined,
                        title: 'Help and Support',
                        subtitle: 'Get help and contact support',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => HelpSupportScreen(),
                            ),
                          );
                        },
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Recent Bookings
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Bookings',
                              style: GoogleFonts.barlow(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                'View all',
                                style: GoogleFonts.barlow(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFE85D04),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 36),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 40,
                                color: isDark
                                    ? Colors.white38
                                    : Colors.grey.withOpacity(0.4),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No bookings yet',
                                style: GoogleFonts.barlow(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Your recent bookings will appear here',
                                style: GoogleFonts.barlow(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.white60
                                      : const Color(0xFF888888),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Fixed: Passing context as parameter
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    required bool showDivider,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        InkWell(
          onTap: onTap ?? () {},
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.barlow(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.barlow(
                          fontSize: 11,
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isDark ? Colors.white60 : const Color(0xFF888888),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(height: 1, indent: 70, color: Color(0xFFEEEEEE)),
      ],
    );
  }
}
