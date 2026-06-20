import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pawffy/features/booking/presentation/my_bookings_screen.dart';

import '../../core/utils/location_provider.dart';
import 'widgets/service_grid.dart';
import 'widgets/provider_card.dart';
import 'widgets/ad_banner.dart';
import '../search/search_screen.dart';
import '../message/message_screen.dart';
import '../profile/profile_screen.dart';
import 'package:pawffy/features/vets/providers/vet_controller.dart';
import 'package:pawffy/features/auth/providers/current_user_provider.dart';
import 'package:pawffy/features/notification/notification_screen.dart';
import 'package:pawffy/features/notification/provider/notification_controller.dart';
import 'package:pawffy/features/vets/vet_list_screen.dart';
import 'package:pawffy/features/vets/vet_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    // ── Watch location providers ───────────────────────
    final locationAsync = ref.watch(locationTextProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // ── Top Bar ────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // location
                          GestureDetector(
                            onTap: () => ref.refresh(positionProvider),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  color: Color(0xFFE85D04),
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                locationAsync.when(
                                  data: (text) => Text(
                                    text,
                                    style: GoogleFonts.barlow(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                  loading: () => Text(
                                    'Getting location...',
                                    style: GoogleFonts.barlow(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  error: (_, __) => Text(
                                    'Location unavailable',
                                    style: GoogleFonts.barlow(
                                      fontSize: 13,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Colors.black54,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),

                          // notification bell
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NotificationScreen(),
                              ),
                            ),
                            child: Stack(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.notifications_outlined,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                    size: 20,
                                  ),
                                ),

                                // Unread dot — only shows when unread count > 0
                                if (ref.watch(unreadCountProvider) > 0)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFE85D04),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── Welcome Text ───────────────────
                      Text(
                        'Welcome,',
                        style: GoogleFonts.barlow(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      ref
                          .watch(currentUserProvider)
                          .when(
                            data: (user) => Text(
                              (user?.name ?? 'there').toUpperCase(),
                              style: GoogleFonts.barlow(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Theme.of(context).colorScheme.onSurface,
                                letterSpacing: 0.5,
                              ),
                            ),
                            loading: () => Container(
                              height: 32,
                              width: 160,
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            error: (_, __) => Text(
                              'THERE',
                              style: GoogleFonts.barlow(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),

                      const SizedBox(height: 18),

                      // ── Search Bar ─────────────────────
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SearchScreen(),
                          ),
                        ),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 14),
                              const Icon(
                                Icons.search_rounded,
                                color: Color(0xFF888888),
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Search by Store Name...',
                                  style: GoogleFonts.barlow(
                                    color: const Color(0xFF888888),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE85D04),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.tune_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Popular Services ───────────────
                      ServiceGrid(
                        onSeeAll: () {},
                        onServiceTap: (service) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VetListScreen(
                                serviceType: service.serviceType,
                                serviceLabel: service.label,
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // ── Ad Banner ──────────────────────
                      const AdBanner(),

                      const SizedBox(height: 24),

                      // ── Adoption Banner ────────────────
                      _buildAdoptionBanner(),

                      const SizedBox(height: 16),

                      // ── Page Indicator ─────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: index == 0 ? 20 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: index == 0
                                  ? const Color(0xFFE85D04)
                                  : const Color(0xFFCCCCCC),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 24),

                      // ── Nearby Providers ───────────────
                      _buildNearbyProviders(),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildAdoptionBanner() {
    return Container(
      width: double.infinity,
      height: 175,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: RadialGradient(
                center: Alignment.centerLeft,
                radius: 1.2,
                colors: [const Color(0xFF2A2A2A), const Color(0xFF111111)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.stars_rounded,
                  color: Color(0xFFE85D04),
                  size: 20,
                ),
                const SizedBox(height: 6),
                Text(
                  'ADOPT LOVE,\nADOPT A FRIEND',
                  style: GoogleFonts.barlow(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.1,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Open your heart and home to furry friend',
                  style: GoogleFonts.barlow(
                    fontSize: 11,
                    color: Colors.white60,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE85D04),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'LEARN MORE',
                          style: GoogleFonts.barlow(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_outward,
                          color: Colors.white,
                          size: 13,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyProviders() {
    final vetsAsync = ref.watch(vetControllerProvider);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'NEARBY PROVIDERS',
              style: GoogleFonts.barlow(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: 0.5,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                'See all',
                style: GoogleFonts.barlow(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFE85D04),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        vetsAsync.when(
          loading: () => const SizedBox(
            height: 230,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => SizedBox(
            height: 230,
            child: Center(
              child: Text(
                'Could not load providers',
                style: GoogleFonts.barlow(color: Colors.grey),
              ),
            ),
          ),
          data: (vets) {
            if (vets.isEmpty) {
              return SizedBox(
                height: 230,
                child: Center(
                  child: Text(
                    'No providers available yet',
                    style: GoogleFonts.barlow(color: Colors.grey),
                  ),
                ),
              );
            }
            return SizedBox(
              height: 230,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: vets.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final vet = vets[index];
                  return ProviderCard(
                    name: vet.clinicName,
                    service: vet.specialization,
                    location: '${vet.city}, ${vet.state}',
                    price: '\$${vet.consultationFee}',
                    rating: vet.rating,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VetDetailScreen(
                          vetId: vet.id,
                          heroClinicName: vet.clinicName,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.search_rounded, 'label': 'Search'},
      {'icon': Icons.calendar_today_outlined, 'label': 'Booking'},
      {'icon': Icons.chat_bubble_outline_rounded, 'label': 'Message'},
      {'icon': Icons.person_outline_rounded, 'label': 'Profile'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isActive = _currentIndex == index;
              return GestureDetector(
                onTap: () {
                  if (index == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    );
                  } else if (index == 2) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (ctx) => MyBookingsScreen()),
                    );
                  } else if (index == 3) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MessageScreen()),
                    );
                  } else if (index == 4) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  } else {
                    setState(() => _currentIndex = index);
                  }
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      items[index]['icon'] as IconData,
                      color: isActive
                          ? const Color(0xFFE85D04)
                          : const Color(0xFF888888),
                      size: 22,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      items[index]['label'] as String,
                      style: GoogleFonts.barlow(
                        fontSize: 10,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isActive
                            ? const Color(0xFFE85D04)
                            : const Color(0xFF888888),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
