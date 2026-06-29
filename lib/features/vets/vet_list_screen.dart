import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:pawffy/features/vets/providers/vet_controller.dart';
import 'package:pawffy/features/vets/data/models/vet_model.dart';
import 'package:pawffy/features/vets/vet_detail_screen.dart';

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

class VetListScreen extends ConsumerStatefulWidget {
  final String serviceType;
  final String serviceLabel;

  const VetListScreen({
    super.key,
    required this.serviceType,
    required this.serviceLabel,
  });

  @override
  ConsumerState<VetListScreen> createState() => _VetListScreenState();
}

class _VetListScreenState extends ConsumerState<VetListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load providers for this serviceType as soon as screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(vetListControllerProvider.notifier)
          .setParams(serviceType: widget.serviceType);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    ref
        .read(vetListControllerProvider.notifier)
        .setParams(
          serviceType: widget.serviceType,
          search: query.isEmpty ? null : query,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vetsAsync = ref.watch(vetListControllerProvider);

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
                        vetsAsync.when(
                          data: (vets) => Text(
                            '${vets.length} provider${vets.length != 1 ? 's' : ''} found',
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

            const SizedBox(height: 20),

            // ── List ─────────────────────────────────────────────────────
            Expanded(
              child: vetsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFFE85D04)),
                ),
                error: (e, _) => _buildError(),
                data: (vets) {
                  if (vets.isEmpty) return _buildEmpty();
                  return RefreshIndicator(
                    color: const Color(0xFFE85D04),
                    onRefresh: () async =>
                        ref.read(vetListControllerProvider.notifier).refresh(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: vets.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) =>
                          _ProviderListCard(vet: vets[index]),
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
            onTap: () => ref.read(vetListControllerProvider.notifier).refresh(),
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
  final VetModel vet;
  const _ProviderListCard({required this.vet});

  @override
  State<_ProviderListCard> createState() => _ProviderListCardState();
}

class _ProviderListCardState extends State<_ProviderListCard> {
  bool _isFavourited = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vet = widget.vet;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                VetDetailScreen(vetId: vet.id, heroClinicName: vet.clinicName),
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
                          '₹${vet.consultationFee}',
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
        _iconForService(widget.vet.serviceType),
        color: const Color(0xFFE85D04).withOpacity(0.4),
        size: 36,
      ),
    );
  }
}
