import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pawffy/features/vets/data/models/vet_model.dart';
import '../providers/booking_controller.dart';
import '../data/models/booking_model.dart';
import 'booking_details_screen.dart';

class BookingSlotsScreen extends ConsumerStatefulWidget {
  final VetModel vet;

  const BookingSlotsScreen({super.key, required this.vet});

  @override
  ConsumerState<BookingSlotsScreen> createState() => _BookingSlotsScreenState();
}

class _BookingSlotsScreenState extends ConsumerState<BookingSlotsScreen> {
  late DateTime _selectedDate;
  String? _selectedSlot;
  VetServiceModel? _selectedService;
  final List<DateTime> _dates = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    // Generate next 14 days
    for (int i = 0; i < 14; i++) {
      _dates.add(DateTime.now().add(Duration(days: i)));
    }
  }

  String _formatDateForApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFFE85D04);

    final dateStr = _formatDateForApi(_selectedDate);
    final slotsAsync = ref.watch(bookingSlotsProvider('${widget.vet.id}|$dateStr'));
    final servicesAsync = ref.watch(vetServicesProvider(widget.vet.id));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'BOOK APPOINTMENT',
          style: GoogleFonts.barlow(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Provider header card
                    _buildProviderCard(isDark),
                    const SizedBox(height: 24),

                    // Section 1: Choose Service
                    _buildSectionHeader('1. SELECT SERVICE'),
                    const SizedBox(height: 12),
                    servicesAsync.when(
                      loading: () => _buildServicesLoadingShimmer(isDark),
                      error: (err, _) => Center(
                        child: Text(
                          'Failed to load services: $err',
                          style: GoogleFonts.barlow(color: Colors.red),
                        ),
                      ),
                      data: (services) {
                        if (services.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'No specific services available. Using general checkup.',
                                style: GoogleFonts.barlow(color: Colors.grey),
                              ),
                            ),
                          );
                        }
                        return _buildServicesList(services, isDark, primaryColor);
                      },
                    ),
                    const SizedBox(height: 24),

                    // Section 2: Date Selector
                    _buildSectionHeader('2. SELECT DATE'),
                    const SizedBox(height: 12),
                    _buildHorizontalCalendar(isDark, primaryColor),
                    const SizedBox(height: 24),

                    // Section 3: Slots Grid
                    _buildSectionHeader('3. AVAILABLE SLOTS'),
                    const SizedBox(height: 12),
                    slotsAsync.when(
                      loading: () => _buildSlotsLoadingShimmer(isDark),
                      error: (err, _) => Center(
                        child: Text(
                          'Failed to load slots: $err',
                          style: GoogleFonts.barlow(color: Colors.red),
                        ),
                      ),
                      data: (slots) {
                        if (slots.isEmpty) {
                          return _buildEmptySlotsState(isDark);
                        }
                        return _buildSlotsGrid(slots, isDark, primaryColor);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Bottom CTA Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ElevatedButton(
                onPressed: (_selectedSlot != null && _selectedService != null)
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingDetailsScreen(
                              vet: widget.vet,
                              selectedDate: _selectedDate,
                              selectedSlot: _selectedSlot!,
                              selectedService: _selectedService!,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  disabledBackgroundColor: primaryColor.withOpacity(0.4),
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                ),
                child: Text(
                  'CONTINUE TO DETAILS',
                  style: GoogleFonts.barlow(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.barlow(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: Colors.grey,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildProviderCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: const Color(0xFFE85D04).withOpacity(0.1),
            backgroundImage: widget.vet.profileImage != null
                ? NetworkImage(widget.vet.profileImage!)
                : null,
            child: widget.vet.profileImage == null
                ? const Icon(Icons.medical_services_outlined, color: Color(0xFFE85D04), size: 28)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.vet.name,
                  style: GoogleFonts.barlow(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  widget.vet.specialization,
                  style: GoogleFonts.barlow(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      widget.vet.rating?.toStringAsFixed(1) ?? 'New',
                      style: GoogleFonts.barlow(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.location_on_outlined, color: Colors.grey, size: 14),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        widget.vet.clinicName,
                        style: GoogleFonts.barlow(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesList(List<VetServiceModel> services, bool isDark, Color primaryColor) {
    // Select first service by default if none selected
    if (_selectedService == null && services.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedService = services.first;
        });
      });
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final service = services[index];
        final isSelected = _selectedService?.id == service.id;

        return InkWell(
          onTap: () {
            setState(() {
              _selectedService = service;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? primaryColor : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                  color: isSelected ? primaryColor : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: GoogleFonts.barlow(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? primaryColor : null,
                        ),
                      ),
                      Text(
                        '${service.duration} mins • ${service.description}',
                        style: GoogleFonts.barlow(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${service.price.toStringAsFixed(0)}',
                  style: GoogleFonts.barlow(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? primaryColor : null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHorizontalCalendar(bool isDark, Color primaryColor) {
    return SizedBox(
      height: 86,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final date = _dates[index];
          final isSelected = DateFormat('yyyy-MM-dd').format(date) ==
              DateFormat('yyyy-MM-dd').format(_selectedDate);
          final dayName = DateFormat('EEE').format(date).toUpperCase();
          final dayNum = DateFormat('dd').format(date);

          return InkWell(
            onTap: () {
              setState(() {
                _selectedDate = date;
                _selectedSlot = null; // Reset slot when date changes
              });
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 62,
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor
                    : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: GoogleFonts.barlow(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white70 : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dayNum,
                    style: GoogleFonts.barlow(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : null,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSlotsGrid(List<String> slots, bool isDark, Color primaryColor) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.2,
      ),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        final isSelected = _selectedSlot == slot;

        return InkWell(
          onTap: () {
            setState(() {
              _selectedSlot = slot;
            });
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryColor
                  : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? primaryColor : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                slot,
                style: GoogleFonts.barlow(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptySlotsState(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          const Icon(Icons.event_busy_rounded, size: 36, color: Colors.grey),
          const SizedBox(height: 10),
          Text(
            'No slots available on this date',
            style: GoogleFonts.barlow(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Please select another day from the calendar above.',
            style: GoogleFonts.barlow(
              fontSize: 12,
              color: Colors.grey.shade400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildServicesLoadingShimmer(bool isDark) {
    return Container(
      height: 70,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(child: CircularProgressIndicator(color: Color(0xFFE85D04))),
    );
  }

  Widget _buildSlotsLoadingShimmer(bool isDark) {
    return Container(
      height: 80,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(child: CircularProgressIndicator(color: Color(0xFFE85D04))),
    );
  }
}
