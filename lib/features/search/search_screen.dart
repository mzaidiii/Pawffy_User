import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // ── Dummy Data ───────────────────────────────────────
  final List<Map<String, dynamic>> _allProviders = [
    {
      'name': 'Happy Paws Sitting',
      'service': 'Pet Sitting',
      'icon': Icons.home_outlined,
      'rating': 4.9,
      'distance': '0.8 mi',
      'price': '\$22/walk',
      'available': true,
    },
    {
      'name': 'Furry Friends Care',
      'service': 'Dog Walking',
      'icon': Icons.directions_walk,
      'rating': 4.7,
      'distance': '1.2 mi',
      'price': '\$18/walk',
      'available': true,
    },
    {
      'name': 'Pawfection Grooming',
      'service': 'Grooming',
      'icon': Icons.content_cut_outlined,
      'rating': 4.8,
      'distance': '2.0 mi',
      'price': '\$35/session',
      'available': false,
    },
    {
      'name': 'The Pet Trainer',
      'service': 'Training',
      'icon': Icons.fitness_center_outlined,
      'rating': 4.6,
      'distance': '1.5 mi',
      'price': '\$50/hr',
      'available': true,
    },
    {
      'name': 'City Vet Clinic',
      'service': 'Vet',
      'icon': Icons.medical_services_outlined,
      'rating': 4.9,
      'distance': '3.1 mi',
      'price': '\$40/visit',
      'available': false,
    },
    {
      'name': 'Cozy Pet Boarding',
      'service': 'Boarding',
      'icon': Icons.night_shelter_outlined,
      'rating': 4.5,
      'distance': '2.8 mi',
      'price': '\$60/night',
      'available': true,
    },
    {
      'name': 'QuickPaws Transport',
      'service': 'Transport',
      'icon': Icons.directions_car_outlined,
      'rating': 4.3,
      'distance': '1.9 mi',
      'price': '\$25/trip',
      'available': false,
    },
    {
      'name': 'Buddy\'s Pet Care',
      'service': 'Pet Sitting',
      'icon': Icons.home_outlined,
      'rating': 4.7,
      'distance': '0.5 mi',
      'price': '\$20/walk',
      'available': true,
    },
  ];

  // ── Filter chips ─────────────────────────────────────
  final List<String> _filters = [
    'All',
    'Pet Sitting',
    'Dog Walking',
    'Grooming',
    'Training',
    'Vet',
    'Boarding',
    'Transport',
  ];
  String _selectedFilter = 'All';

  // ── Filtered list ────────────────────────────────────
  List<Map<String, dynamic>> get _filteredProviders {
    return _allProviders.where((p) {
      final matchesSearch =
          p['name'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          p['service'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      final matchesFilter =
          _selectedFilter == 'All' || p['service'] == _selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // ── Top Bar with back + title ──────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.black87,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'SEARCH',
                    style: GoogleFonts.barlow(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Search Bar ────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: GoogleFonts.barlow(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search providers or services...',
                    hintStyle: GoogleFonts.barlow(
                      color: const Color(0xFF888888),
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF888888),
                      size: 20,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            child: const Icon(
                              Icons.close_rounded,
                              color: Color(0xFF888888),
                              size: 18,
                            ),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFFE85D04),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Filter Chips (placeholder) ────────────
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFE85D04)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Text(
                        filter,
                        style: GoogleFonts.barlow(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF888888),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // ── Results count ─────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '${_filteredProviders.length} providers found',
                style: GoogleFonts.barlow(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF888888),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ── Provider List ─────────────────────────
            Expanded(
              child: _filteredProviders.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _filteredProviders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _buildProviderCard(_filteredProviders[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Provider Card ─────────────────────────────────────
  Widget _buildProviderCard(Map<String, dynamic> provider) {
    final bool isAvailable = provider['available'] as bool;

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Left Icon ───────────────────────────
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFE85D04).withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                provider['icon'] as IconData,
                color: const Color(0xFFE85D04),
                size: 26,
              ),
            ),
            const SizedBox(width: 14),

            // ── Middle Content ───────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // provider name — heading
                  Text(
                    provider['name'],
                    style: GoogleFonts.barlow(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),

                  // service type
                  Text(
                    provider['service'],
                    style: GoogleFonts.barlow(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF888888),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // rating + distance row
                  Row(
                    children: [
                      // ⭐ rating
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFA500),
                        size: 15,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        provider['rating'].toString(),
                        style: GoogleFonts.barlow(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(width: 14),

                      // 📍 distance
                      const Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: Color(0xFF888888),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        provider['distance'],
                        style: GoogleFonts.barlow(
                          fontSize: 12,
                          color: const Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // price + availability row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // price
                      Text(
                        provider['price'],
                        style: GoogleFonts.barlow(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFE85D04),
                        ),
                      ),

                      // availability badge — bottom right
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? const Color(0xFF22C55E).withOpacity(0.12)
                              : const Color(0xFF888888).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isAvailable
                                ? const Color(0xFF22C55E)
                                : const Color(0xFF888888),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isAvailable
                                    ? const Color(0xFF22C55E)
                                    : const Color(0xFF888888),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isAvailable ? 'Available Now' : 'Available Later',
                              style: GoogleFonts.barlow(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isAvailable
                                    ? const Color(0xFF22C55E)
                                    : const Color(0xFF888888),
                              ),
                            ),
                          ],
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
    );
  }

  // ── Empty State ───────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 60,
            color: Colors.grey.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No providers found',
            style: GoogleFonts.barlow(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try a different search or filter',
            style: GoogleFonts.barlow(
              fontSize: 13,
              color: const Color(0xFF888888),
            ),
          ),
        ],
      ),
    );
  }
}
