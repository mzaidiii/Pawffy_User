import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProviderCard extends StatefulWidget {
  final String name;
  final String service;
  final String distance;
  final String price;
  final double rating;

  const ProviderCard({
    super.key,
    required this.name,
    required this.service,
    required this.distance,
    required this.price,
    required this.rating,
  });

  @override
  State<ProviderCard> createState() => _ProviderCardState();
}

class _ProviderCardState extends State<ProviderCard> {
  bool _isFavourited = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image Placeholder + badges ──────────────
            Stack(
              children: [
                // image placeholder
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: const Icon(
                    Icons.pets,
                    color: Color(0xFFBBBBBB),
                    size: 36,
                  ),
                ),

                // ── Rating badge top left ───────────────
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFA500),
                          size: 13,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          widget.rating.toString(),
                          style: GoogleFonts.barlow(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Heart icon top right ────────────────
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => setState(() => _isFavourited = !_isFavourited),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isFavourited
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: _isFavourited
                            ? const Color(0xFFE85D04)
                            : Colors.grey,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Details ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // name
                  Text(
                    widget.name,
                    style: GoogleFonts.barlow(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  // service type
                  Text(
                    widget.service,
                    style: GoogleFonts.barlow(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF888888),
                    ),
                  ),
                  const SizedBox(height: 2),

                  // distance
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 11,
                        color: Color(0xFF888888),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        widget.distance,
                        style: GoogleFonts.barlow(
                          fontSize: 11,
                          color: const Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // price
                  Text(
                    widget.price,
                    style: GoogleFonts.barlow(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFE85D04),
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
}
