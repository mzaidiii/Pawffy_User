import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/booking_controller.dart';
import '../data/models/booking_model.dart';
import '../../home/home_screen.dart';

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
          'BOOKING CONFIRMED',
          style: GoogleFonts.barlow(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        automaticallyImplyLeading: false, // Don't allow going back to payment screens
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
                        // Success Checkmark Illustration
                        const SizedBox(height: 10),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: Colors.green,
                              size: 54,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Appointment Placed Successfully!',
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
                            color: Colors.green,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // Receipt Details
                        _buildReceiptCard(booking, isDark, primaryColor),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Back to home button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
                      ),
                    ),
                    child: Text(
                      'GO TO HOME',
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
            );
          },
        ),
      ),
    );
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
