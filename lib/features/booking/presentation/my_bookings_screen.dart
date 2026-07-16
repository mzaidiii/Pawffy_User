import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/booking_controller.dart';
import '../data/models/booking_model.dart';
import '../../search/search_screen.dart';
import 'payment_summary_screen.dart';
import 'booking_confirmation_screen.dart';

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(myBookingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFFE85D04);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'MY APPOINTMENTS',
          style: GoogleFonts.barlow(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        automaticallyImplyLeading: false, // In bottom navigation, back button is not needed
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: primaryColor,
          onRefresh: () async {
            ref.invalidate(myBookingsProvider);
          },
          child: bookingsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFFE85D04)),
            ),
            error: (err, _) => Center(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load bookings',
                      style: GoogleFonts.barlow(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      err.toString().replaceAll('Exception:', '').trim(),
                      style: GoogleFonts.barlow(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(myBookingsProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('RETRY'),
                    ),
                  ],
                ),
              ),
            ),
            data: (bookings) {
              if (bookings.isEmpty) {
                return _buildEmptyState(context, isDark, primaryColor);
              }
              // Sort bookings by date descending
              final sortedBookings = List<BookingModel>.from(bookings)
                ..sort((a, b) => b.bookingDate.compareTo(a.bookingDate));

              return ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                itemCount: sortedBookings.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final booking = sortedBookings[index];
                  return _buildBookingCard(context, booking, isDark, primaryColor);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark, Color primaryColor) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.calendar_today_outlined, size: 48, color: primaryColor),
            ),
            const SizedBox(height: 20),
            Text(
              'No Appointments Yet',
              style: GoogleFonts.barlow(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Book an appointment with our trusted professionals.',
              style: GoogleFonts.barlow(
                fontSize: 13,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(27),
                ),
              ),
              child: Text(
                'BOOK APPOINTMENT',
                style: GoogleFonts.barlow(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(
      BuildContext context, BookingModel booking, bool isDark, Color primaryColor) {
    // Determine status color
    Color statusBgColor;
    Color statusTextColor;
    if (booking.status.toLowerCase() == 'confirmed') {
      statusBgColor = Colors.green.withOpacity(0.12);
      statusTextColor = Colors.green;
    } else if (booking.status.toLowerCase() == 'cancelled') {
      statusBgColor = Colors.red.withOpacity(0.12);
      statusTextColor = Colors.red;
    } else {
      statusBgColor = Colors.orange.withOpacity(0.12);
      statusTextColor = Colors.orange;
    }

    return InkWell(
      onTap: () {
        if (booking.status.toLowerCase() == 'pending') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentSummaryScreen(booking: booking),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookingConfirmationScreen(bookingId: booking.id),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Service name + Status Badge + Chevron Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking.service.name.toUpperCase(),
                    style: GoogleFonts.barlow(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: primaryColor,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        booking.status.toUpperCase(),
                        style: GoogleFonts.barlow(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: statusTextColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.grey,
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Provider info (Vendor Name)
            Text(
              booking.vet.name.isNotEmpty ? booking.vet.name : 'Unknown Provider',
              style: GoogleFonts.barlow(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            
            // Clinic name and phone (Contact Details)
            Text(
              [
                if (booking.vet.clinicName.isNotEmpty) booking.vet.clinicName,
                if (booking.vet.phone != null && booking.vet.phone!.isNotEmpty) booking.vet.phone!,
              ].join(' • '),
              style: GoogleFonts.barlow(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),

            // Notes info (conditionally shown if present)
            if (booking.notes != null && booking.notes!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Notes: ${booking.notes}',
                style: GoogleFonts.barlow(
                  fontSize: 13,
                  color: Colors.grey.shade400,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const Divider(height: 24, thickness: 0.8),

            // Details grid (Pet, Date, Time)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSmallCardDetail(
                  'PET',
                  booking.pet.name.isNotEmpty ? booking.pet.name : 'N/A',
                ),
                _buildSmallCardDetail(
                  'DATE',
                  booking.dateTimeFormatted ?? DateFormat('dd MMM yyyy').format(booking.bookingDate),
                ),
                _buildSmallCardDetail(
                  'TIME',
                  booking.bookingTime.isNotEmpty ? booking.bookingTime : 'N/A',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallCardDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.barlow(
            fontSize: 10,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.barlow(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
