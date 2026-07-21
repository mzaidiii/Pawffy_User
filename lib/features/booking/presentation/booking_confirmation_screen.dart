import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pawffy/core/storage/storage_service.dart';
import '../providers/booking_controller.dart';
import '../data/models/booking_model.dart';
import '../../home/home_screen.dart';
import 'review_vendor_sheet.dart';

class BookingConfirmationScreen extends ConsumerWidget {
  final String bookingId;

  const BookingConfirmationScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingDetailsAsync = ref.watch(bookingDetailsProvider(bookingId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFFE85D04);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'BOOKING DETAILS',
          style: GoogleFonts.barlow(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: bookingDetailsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFE85D04)),
          ),
          error: (err, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text(
                  'Failed to fetch booking details: $err',
                  style: GoogleFonts.barlow(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text('GO HOME'),
                ),
              ],
            ),
          ),
          data: (booking) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: _statusColor(booking.status).withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              _statusIcon(booking.status),
                              color: _statusColor(booking.status),
                              size: 54,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _statusTitle(booking.status),
                          style: GoogleFonts.barlow(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your booking status is currently: ${booking.status.toUpperCase()}',
                          style: GoogleFonts.barlow(
                            fontSize: 13,
                            color: _statusColor(booking.status),
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        _buildReceiptCard(booking, isDark, primaryColor),
                        const SizedBox(height: 24),
                        if (booking.status.toLowerCase() == 'completed')
                          _reviewPrompt(context, ref, booking, isDark),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    if (booking.status.toLowerCase() == 'pending' || booking.status.toLowerCase() == 'confirmed')
                      OutlinedButton(
                        onPressed: () => _cancelBooking(context, ref),
                        style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50), foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27))),
                        child: Text('CANCEL BOOKING', style: GoogleFonts.barlow(fontWeight: FontWeight.w800)),
                      ),
                    if (booking.status.toLowerCase() == 'pending' || booking.status.toLowerCase() == 'confirmed') const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (route) => false),
                      style: ElevatedButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size(double.infinity, 54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27))),
                      child: Text('GO TO HOME', style: GoogleFonts.barlow(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1.1)),
                    ),
                  ]),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return Colors.teal;
      case 'cancelled': case 'rejected': return Colors.red;
      case 'pending': return Colors.orange;
      default: return Colors.green;
    }
  }

  static IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return Icons.celebration_rounded;
      case 'cancelled': case 'rejected': return Icons.cancel_rounded;
      case 'pending': return Icons.hourglass_top_rounded;
      default: return Icons.check_circle_rounded;
    }
  }

  static String _statusTitle(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return 'Service completed!';
      case 'cancelled': return 'Booking cancelled';
      case 'rejected': return 'Booking rejected';
      case 'pending': return 'Payment pending';
      default: return 'Appointment confirmed!';
    }
  }

  Widget _reviewPrompt(BuildContext context, WidgetRef ref, BookingModel booking, bool isDark) {
    return FutureBuilder<bool>(
      future: StorageService.isBookingReviewed(booking.id),
      builder: (context, snapshot) {
        final bool isAlreadyReviewed = booking.isReviewed || (snapshot.data == true);

        if (isAlreadyReviewed) {
          final reviewRating = int.tryParse(booking.review?['rating']?.toString() ?? '') ?? 5;
          final reviewComment = booking.review?['comment']?.toString() ?? '';

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.green, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'REVIEW SUBMITTED',
                      style: GoogleFonts.barlow(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.green,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    return Icon(
                      Icons.star_rounded,
                      size: 20,
                      color: i < reviewRating ? const Color(0xFFFFB703) : Colors.grey.shade300,
                    );
                  }),
                ),
                if (reviewComment.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '"$reviewComment"',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.barlow(
                      fontSize: 13,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  'Thank you for rating ${booking.vet.name}!',
                  style: GoogleFonts.barlow(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFE85D04).withOpacity(.08),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              const Icon(Icons.star_rounded, size: 38, color: Color(0xFFE85D04)),
              const SizedBox(height: 6),
              Text(
                'Enjoyed the service?',
                style: GoogleFonts.barlow(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Share your experience with other pet parents.',
                textAlign: TextAlign.center,
                style: GoogleFonts.barlow(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await showModalBottomSheet<bool>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    builder: (_) => ReviewVendorSheet(
                      bookingId: booking.id,
                      vendorId: booking.vet.id,
                      vendorName: booking.vet.name,
                    ),
                  );
                  if (result == true) {
                    ref.invalidate(bookingDetailsProvider(booking.id));
                  }
                },
                icon: const Icon(Icons.rate_review_rounded),
                label: const Text('RATE VENDOR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE85D04),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _cancelBooking(BuildContext context, WidgetRef ref) async {
    final allowed = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(title: const Text('Cancel booking?'), content: const Text('This will cancel your booking. Any eligible refund is handled by Pawffy.'), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('KEEP')), TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('CANCEL BOOKING'))]));
    if (allowed != true) return;
    try {
      await ref.read(bookingControllerProvider.notifier).cancelBooking(bookingId);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking cancelled successfully')));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    }
  }

  Widget _buildReceiptCard(BookingModel booking, bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Appointment ID
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'APPOINTMENT ID',
                style: GoogleFonts.barlow(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey,
                ),
              ),
              Text(
                booking.appointmentId ?? 'N/A',
                style: GoogleFonts.barlow(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const Divider(height: 30, thickness: 0.8),

          // Provider details
          Text(
            'SERVICE PROVIDER',
            style: GoogleFonts.barlow(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            booking.vet.name,
            style: GoogleFonts.barlow(
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            '${booking.vet.clinicName}${booking.vet.clinicAddress != null ? " • ${booking.vet.clinicAddress}" : ""}',
            style: GoogleFonts.barlow(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          if (booking.vet.phone != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.phone_rounded, color: primaryColor, size: 12),
                const SizedBox(width: 4),
                Text(
                  booking.vet.phone!,
                  style: GoogleFonts.barlow(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          const Divider(height: 30, thickness: 0.8),

          // Date and Time
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DATE',
                      style: GoogleFonts.barlow(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.dateTimeFormatted ?? DateFormat('dd MMM yyyy').format(booking.bookingDate),
                      style: GoogleFonts.barlow(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TIME SLOT',
                      style: GoogleFonts.barlow(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.bookingTime,
                      style: GoogleFonts.barlow(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 30, thickness: 0.8),

          // Pet Details
          Text(
            'PET NAME',
            style: GoogleFonts.barlow(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${booking.pet.name} (${booking.pet.breed ?? booking.pet.species})',
            style: GoogleFonts.barlow(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Divider(height: 30, thickness: 0.8),

          // Payment info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PAYMENT METHOD',
                    style: GoogleFonts.barlow(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    booking.payment?.paymentMethod?.toUpperCase() ?? 'WALLET',
                    style: GoogleFonts.barlow(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'TOTAL PAID',
                    style: GoogleFonts.barlow(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${booking.payment?.amount.toStringAsFixed(2) ?? booking.service.price.toStringAsFixed(2)}',
                    style: GoogleFonts.barlow(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFE85D04),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
