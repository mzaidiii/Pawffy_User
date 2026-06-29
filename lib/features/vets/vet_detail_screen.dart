import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:pawffy/features/vets/data/models/vet_model.dart';
import 'package:pawffy/features/vets/providers/vet_controller.dart';
import 'package:pawffy/features/message/chat_screen.dart';
import 'package:pawffy/features/booking/presentation/booking_slots_screen.dart';

class VetDetailScreen extends ConsumerStatefulWidget {
  final String vetId;
  final String? heroClinicName;

  const VetDetailScreen({super.key, required this.vetId, this.heroClinicName});

  @override
  ConsumerState<VetDetailScreen> createState() => _VetDetailScreenState();
}

class _VetDetailScreenState extends ConsumerState<VetDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(vetDetailControllerProvider.notifier).loadVet(widget.vetId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vetAsync = ref.watch(vetDetailControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: vetAsync.when(
        loading: () => _buildLoading(),
        error: (e, _) => _buildError(),
        data: (vet) {
          if (vet == null) return _buildLoading();
          return _buildContent(vet, isDark);
        },
      ),
      bottomNavigationBar: vetAsync.when(
        loading: () => null,
        error: (e, _) => null,
        data: (vet) {
          if (vet == null) return null;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: _buildBottomActions(vet, isDark),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomActions(VetModel vet, bool isDark) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: () {
              final rId = vet.userId ?? vet.id;
              if (rId.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cannot start a chat with this provider')),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    receiverId: rId,
                    receiverName: vet.name,
                    receiverProfileImage: vet.profileImage,
                  ),
                ),
              );
            },
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF232323) : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: const Color(0xFFE85D04),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Color(0xFFE85D04),
                  size: 22,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookingSlotsScreen(vet: vet),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE85D04),
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: const Color(0xFFE85D04).withOpacity(0.3),
            ),
            child: Text(
              'BOOK APPOINTMENT',
              style: GoogleFonts.barlow(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return SafeArea(
      child: Column(
        children: [
          _backButton(),
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFFE85D04)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return SafeArea(
      child: Column(
        children: [
          _backButton(),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.wifi_off_rounded,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Could not load provider',
                    style: GoogleFonts.barlow(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => ref
                        .read(vetDetailControllerProvider.notifier)
                        .refresh(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(VetModel vet, bool isDark) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 260,
          pinned: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                vet.profileImage != null
                    ? Image.network(
                        vet.profileImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imageFallback(vet),
                      )
                    : _imageFallback(vet),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: vet.availableStatus ? Colors.green : Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          vet.availableStatus ? 'Available' : 'Unavailable',
                          style: GoogleFonts.barlow(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vet.clinicName,
                        style: GoogleFonts.barlow(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        vet.name,
                        style: GoogleFonts.barlow(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _statCard(
                      icon: Icons.star_rounded,
                      iconColor: Colors.amber,
                      label: 'Rating',
                      value: vet.rating != null
                          ? vet.rating!.toStringAsFixed(1)
                          : 'New',
                      isDark: isDark,
                    ),
                    const SizedBox(width: 12),
                    _statCard(
                      icon: Icons.work_outline_rounded,
                      iconColor: const Color(0xFFE85D04),
                      label: 'Experience',
                      value: '${vet.experienceYears} yrs',
                      isDark: isDark,
                    ),
                    const SizedBox(width: 12),
                    _statCard(
                      icon: Icons.calendar_today_outlined,
                      iconColor: Colors.blue,
                      label: 'Bookings',
                      value: '${vet.bookingCount}',
                      isDark: isDark,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                _sectionTitle('About'),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _infoRow(
                        Icons.medical_services_outlined,
                        'Specialization',
                        vet.specialization,
                      ),
                      const SizedBox(height: 10),
                      _infoRow(
                        Icons.category_outlined,
                        'Service Type',
                        vet.serviceType.toUpperCase(),
                      ),
                      if (vet.phone != null) ...[
                        const SizedBox(height: 10),
                        _infoRow(Icons.phone_outlined, 'Phone', vet.phone!),
                      ],
                      if (vet.email.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _infoRow(Icons.email_outlined, 'Email', vet.email),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                _sectionTitle('Location'),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (vet.clinicName.isNotEmpty)
                        _infoRow(
                          Icons.local_hospital_outlined,
                          'Clinic',
                          vet.clinicName,
                        ),
                      if (vet.clinicAddress != null) ...[
                        const SizedBox(height: 10),
                        _infoRow(
                          Icons.location_on_outlined,
                          'Address',
                          vet.clinicAddress!,
                        ),
                      ],
                      const SizedBox(height: 10),
                      _infoRow(
                        Icons.map_outlined,
                        'City & State',
                        '${vet.city}, ${vet.state}',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                _sectionTitle('Reviews'),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.star_border_rounded,
                        size: 40,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No reviews yet',
                        style: GoogleFonts.barlow(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Be the first to leave a review after your visit!',
                        style: GoogleFonts.barlow(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _backButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF232323)
                  : Colors.white,
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
      ),
    );
  }

  Widget _imageFallback(VetModel vet) {
    return Container(
      color: const Color(0xFFE85D04).withOpacity(0.1),
      child: Center(
        child: Icon(
          Icons.medical_services_outlined,
          size: 80,
          color: const Color(0xFFE85D04).withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.barlow(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: Colors.grey,
        letterSpacing: 1,
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.barlow(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.barlow(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFFE85D04)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.barlow(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.barlow(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
