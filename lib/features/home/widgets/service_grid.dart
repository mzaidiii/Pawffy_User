import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ServiceItem {
  final String label;
  final IconData icon;

  const ServiceItem({required this.label, required this.icon});
}

final List<ServiceItem> popularServices = [
  ServiceItem(label: 'Pet Sitting', icon: Icons.home_outlined),
  ServiceItem(label: 'Dog Walking', icon: Icons.directions_walk),
  ServiceItem(label: 'Grooming', icon: Icons.content_cut_outlined),
  ServiceItem(label: 'Training', icon: Icons.fitness_center_outlined),
  ServiceItem(label: 'Vet', icon: Icons.medical_services_outlined),
  ServiceItem(label: 'Boarding', icon: Icons.night_shelter_outlined),
  ServiceItem(label: 'Transport', icon: Icons.directions_car_outlined),
  ServiceItem(label: 'More', icon: Icons.grid_view_rounded),
];

class ServiceGrid extends StatelessWidget {
  final VoidCallback onSeeAll;

  const ServiceGrid({super.key, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
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
                color: Colors.black,
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
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, index) {
            final item = popularServices[index];
            return InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              child: Column(
                children: [
                  // icon container
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        item.icon,
                        color: const Color(0xFFE85D04),
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),

                  // label
                  Text(
                    item.label,
                    style: GoogleFonts.barlow(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
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
}
