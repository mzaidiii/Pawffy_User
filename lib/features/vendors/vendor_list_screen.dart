import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:pawffy/features/vendors/providers/vendor_controller.dart';
import 'package:pawffy/features/vendors/data/models/vendor_model.dart';
import 'package:pawffy/features/vendors/vendor_detail_screen.dart';
import 'package:pawffy/core/utils/location_provider.dart';

IconData _iconForService(String serviceType) {
  switch (serviceType) {
    case 'groomer':
      return Icons.content_cut_outlined;
    case 'walker':
      return Icons.directions_walk_rounded;
    case 'trainer':
      return Icons.fitness_center_outlined;
    case 'sitter':
      return Icons.home_outlined;
    case 'poop_scooper':
      return Icons.cleaning_services_outlined;
    default:
      return Icons.medical_services_outlined;
  }
}

class VendorListScreen extends ConsumerStatefulWidget {
  final String serviceType;
  final String serviceLabel;

  const VendorListScreen({
    super.key,
    required this.serviceType,
    required this.serviceLabel,
  });

  @override
  ConsumerState<VendorListScreen> createState() => _VendorListScreenState();
}

class _VendorListScreenState extends ConsumerState<VendorListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showOnlineOnly = false;
  bool _filterByCity = false;

  @override
  void initState() {
    super.initState();
    // Load providers for this serviceType as soon as screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final placemark = ref.read(placemarkProvider).value;
      final city = placemark?.locality;
      ref
          .read(vendorListControllerProvider.notifier)
          .setParams(
            serviceType: widget.serviceType,
            city: _filterByCity ? city : null,
          );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    final placemark = ref.read(placemarkProvider).value;
    final city = placemark?.locality;
    ref
        .read(vendorListControllerProvider.notifier)
        .setParams(
          serviceType: widget.serviceType,
          search: query.isEmpty ? null : query,
          city: _filterByCity ? city : null,
          isOnline: _showOnlineOnly ? true : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vendorsAsync = ref.watch(vendorListControllerProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF232323) : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.serviceLabel.toUpperCase(),
                          style: GoogleFonts.barlow(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).colorScheme.onSurface,
                            letterSpacing: 0.5,
                          ),
                        ),
                        vendorsAsync.when(
                          data: (vendors) => Text(
                            '${vendors.length} provider${vendors.length != 1 ? 's' : ''} found',
                            style: GoogleFonts.barlow(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          loading: () => Text(
                            'Loading...',
                            style: GoogleFonts.barlow(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE85D04).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _iconForService(widget.serviceType),
                      color: const Color(0xFFE85D04),
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),

            // ── Search Bar ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearch,
                        style: GoogleFonts.barlow(fontSize: 14),
                        decoration: InputDecoration(
                          hintText:
                              'Search ${widget.serviceLabel.toLowerCase()}s...',
                          hintStyle: GoogleFonts.barlow(
                            fontSize: 14,
                            color: const Color(0xFF888888),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          filled: false,
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.grey,
                            size: 18,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Filter Chips ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Online Only Chip
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showOnlineOnly = !_showOnlineOnly;
                      });
                      final placemark = ref.read(placemarkProvider).value;
                      final city = placemark?.locality;
                      ref.read(vendorListControllerProvider.notifier).setParams(
                            serviceType: widget.serviceType,
                            search: _searchController.text.isNotEmpty
                                ? _searchController.text
                                : null,
                            city: _filterByCity ? city : null,
                            isOnline: _showOnlineOnly ? true : null,
                          );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: _showOnlineOnly
                            ? const Color(0xFFE85D04)
                            : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _showOnlineOnly
                              ? Colors.transparent
                              : (isDark ? Colors.white24 : Colors.grey.shade300),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            color: _showOnlineOnly ? Colors.white : Colors.green,
                            size: 8,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Online Only',
                            style: GoogleFonts.barlow(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _showOnlineOnly
                                  ? Colors.white
                                  : (isDark ? Colors.white70 : Colors.grey.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Builder(builder: (context) {
                    final placemark = ref.watch(placemarkProvider).value;
                    final city = placemark?.locality;
                    if (city != null && city.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _filterByCity = !_filterByCity;
                            });
                            ref.read(vendorListControllerProvider.notifier).setParams(
                                  serviceType: widget.serviceType,
                                  search: _searchController.text.isNotEmpty
                                      ? _searchController.text
                                      : null,
                                  city: _filterByCity ? city : null,
                                  isOnline: _showOnlineOnly ? true : null,
                                );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: _filterByCity
                                  ? const Color(0xFFE85D04)
                                  : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _filterByCity
                                    ? Colors.transparent
                                    : (isDark ? Colors.white24 : Colors.grey.shade300),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  color: _filterByCity ? Colors.white : const Color(0xFFE85D04),
                                  size: 12,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'In $city',
                                  style: GoogleFonts.barlow(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _filterByCity
                                        ? Colors.white
                                        : (isDark ? Colors.white70 : Colors.grey.shade700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── List ─────────────────────────────────────────────────────
            Expanded(
              child: vendorsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFFE85D04)),
                ),
                error: (e, _) => _buildError(),
                data: (vendors) {
                  if (vendors.isEmpty) return _buildEmpty();
                  return RefreshIndicator(
                    color: const Color(0xFFE85D04),
                    onRefresh: () async =>
                        ref.read(vendorListControllerProvider.notifier).refresh(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: vendors.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) =>
                          _ProviderListCard(vendor: vendors[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _iconForService(widget.serviceType),
            size: 60,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No ${widget.serviceLabel}s found',
            style: GoogleFonts.barlow(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _searchController.text.isNotEmpty
                ? 'Try a different search term'
                : 'Check back soon — more providers are joining!',
            style: GoogleFonts.barlow(
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            'Could not load providers',
            style: GoogleFonts.barlow(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => ref.read(vendorListControllerProvider.notifier).refresh(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE85D04),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.barlow(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── _ProviderListCard ─────────────────────────────────────────────────────

class _ProviderListCard extends StatefulWidget {
  final VendorModel vendor;
  const _ProviderListCard({required this.vendor});

  @override
  State<_ProviderListCard> createState() => _ProviderListCardState();
}

class _ProviderListCardState extends State<_ProviderListCard> {
  bool _isFavourited = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vet = widget.vendor;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                VendorDetailScreen(vendorId: vet.id, heroClinicName: vet.clinicName),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Container(
                width: 100,
                height: 110,
                color: const Color(0xFFE85D04).withOpacity(0.08),
                child: vet.profileImage != null
                    ? Image.network(
                        vet.profileImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            vet.clinicName,
                            style: GoogleFonts.barlow(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _isFavourited = !_isFavourited),
                          child: Icon(
                            _isFavourited
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: _isFavourited
                                ? const Color(0xFFE85D04)
                                : Colors.grey,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      vet.specialization,
                      style: GoogleFonts.barlow(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: Color(0xFF888888),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${vet.city}, ${vet.state}',
                          style: GoogleFonts.barlow(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '\$${vet.consultationFee}',
                          style: GoogleFonts.barlow(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFE85D04),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 12,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                vet.rating != null
                                    ? vet.rating!.toStringAsFixed(1)
                                    : 'New',
                                style: GoogleFonts.barlow(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.amber.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: vet.availableStatus
                                ? Colors.green
                                : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Center(
      child: Icon(
        _iconForService(widget.vendor.serviceType),
        color: const Color(0xFFE85D04).withOpacity(0.4),
        size: 36,
      ),
    );
  }
}
