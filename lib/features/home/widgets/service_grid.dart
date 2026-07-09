import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ServiceItem {
  final String label;
  final IconData icon;
  final String serviceType; // matches backend serviceType param
  final bool comingSoon;

  const ServiceItem({
    required this.label,
    required this.icon,
    required this.serviceType,
    this.comingSoon = false,
  });
}

final List<ServiceItem> popularServices = [
  ServiceItem(
    label: 'Veterinarian',
    icon: Icons.medical_services_outlined,
    serviceType: 'vet',
  ),
  ServiceItem(
    label: 'Grooming',
    icon: Icons.content_cut_outlined,
    serviceType: 'groomer',
  ),
  ServiceItem(
    label: 'Walker',
    icon: Icons.directions_walk_rounded,
    serviceType: 'walker',
  ),
  ServiceItem(
    label: 'Trainer',
    icon: Icons.fitness_center_outlined,
    serviceType: 'trainer',
  ),
  ServiceItem(
    label: 'Pet Sitter',
    icon: Icons.home_outlined,
    serviceType: 'sitter',
  ),
  ServiceItem(
    label: 'Poop Scooper',
    icon: Icons.cleaning_services_outlined,
    serviceType: 'poop_scooper',
  ),
  ServiceItem(
    label: 'Adoption',
    icon: Icons.favorite_outline_rounded,
    serviceType: 'adoption',
    comingSoon: true,
  ),
  ServiceItem(
    label: 'Lost & Found',
    icon: Icons.search_rounded,
    serviceType: 'lost_found',
    comingSoon: false,
  ),
];

class ServiceGrid extends StatelessWidget {
  final VoidCallback onSeeAll;
  final void Function(ServiceItem service) onServiceTap;

  const ServiceGrid({
    super.key,
    required this.onSeeAll,
    required this.onServiceTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // ── Header ──────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'POPULAR SERVICES',
              style: GoogleFonts.barlow(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: 0.5,
              ),
            ),
            GestureDetector(
              onTap: onSeeAll,
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

        // ── Grid ────────────────────────────────────────
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: popularServices.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.82,
          ),
          itemBuilder: (context, index) {
            final item = popularServices[index];
            return GestureDetector(
              onTap: () {
                if (item.comingSoon) {
                  _showComingSoon(context, item.label);
                } else {
                  onServiceTap(item);
                }
              },
              child: Column(
                children: [
                  // ── Icon Box ──────────────────────────
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF232323) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            item.icon,
                            color: item.comingSoon
                                ? Colors.grey
                                : const Color(0xFFE85D04),
                            size: 26,
                          ),
                          // coming soon lock badge
                          if (item.comingSoon)
                            Positioned(
                              top: 5,
                              right: 5,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade400,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.lock_rounded,
                                  size: 8,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),

                  // ── Label ─────────────────────────────
                  Text(
                    item.label,
                    style: GoogleFonts.barlow(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: item.comingSoon
                          ? Colors.grey
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$label is coming soon! 🐾',
          style: GoogleFonts.barlow(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFFE85D04),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
