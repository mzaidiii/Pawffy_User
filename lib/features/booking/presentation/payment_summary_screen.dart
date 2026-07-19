import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/intl.dart';
import '../data/models/booking_model.dart';
import '../providers/booking_controller.dart';
import 'booking_confirmation_screen.dart';

class PaymentSummaryScreen extends ConsumerStatefulWidget {
  final BookingModel booking;

  const PaymentSummaryScreen({super.key, required this.booking});

  @override
  ConsumerState<PaymentSummaryScreen> createState() =>
      _PaymentSummaryScreenState();
}

class _PaymentSummaryScreenState extends ConsumerState<PaymentSummaryScreen> {
  final _couponController = TextEditingController();
  String? _appliedCoupon;
  String _paymentMethod = 'wallet';
  bool _isCouponLoading = false;
  String? _couponError;
  String? _couponSuccessMessage;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _applyCouponCode() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _isCouponLoading = true;
      _couponError = null;
      _couponSuccessMessage = null;
    });

    try {
      final service = ref.read(bookingServiceProvider);
      final response = await service.applyCoupon(widget.booking.id, code);

      if (response['success'] == true) {
        setState(() {
          _appliedCoupon = code;
          _couponSuccessMessage =
              response['message'] ?? 'Coupon applied successfully!';
          _isCouponLoading = false;
        });
        // Refetch summary
        ref.invalidate(
          paymentSummaryProvider(
            '${widget.booking.id}|${_appliedCoupon ?? ""}',
          ),
        );
      } else {
        setState(() {
          _couponError = response['message'] ?? 'Invalid coupon code';
          _isCouponLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _couponError = e.toString().replaceAll('Exception:', '').trim();
        _isCouponLoading = false;
      });
    }
  }

  Future<void> _processPayment(double totalAmount) async {
    final paymentNotifier = ref.read(paymentControllerProvider.notifier);

    if (_paymentMethod == 'wallet') {
      try {
        final result = await paymentNotifier.payWithWallet(
          widget.booking.id,
          couponCode: _appliedCoupon,
        );
        if (result['success'] == true && mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  BookingConfirmationScreen(bookingId: widget.booking.id),
            ),
            (route) => route.isFirst,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Wallet Payment Failed: $e')));
        }
      }
    } else {
      // Stripe Card Payment
      try {
        final publishableKey = await ref
            .read(bookingServiceProvider)
            .getStripePublishableKey();
        Stripe.publishableKey = publishableKey;
        await Stripe.instance.applySettings();

        // 1. Create Payment Intent on backend
        final intent = await paymentNotifier.createStripeIntent(
          widget.booking.id,
          couponCode: _appliedCoupon,
        );

        // 2. Initialize native Stripe payment sheet
        final isDark = Theme.of(context).brightness == Brightness.dark;
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: intent.clientSecret,
            merchantDisplayName: 'Pawffy Inc.',
            style: isDark ? ThemeMode.dark : ThemeMode.light,
            appearance: PaymentSheetAppearance(
              colors: PaymentSheetAppearanceColors(
                primary: const Color(0xFFE85D04),
                background: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              ),
            ),
          ),
        );

        // 3. Present the native Stripe payment sheet
        await Stripe.instance.presentPaymentSheet();

        // 4. Verify payment status on backend
        final verifyResult = await paymentNotifier.verifyStripePayment(
          intent.paymentIntentId,
        );

        if (verifyResult['success'] == true && mounted) {
          ref.invalidate(bookingDetailsProvider(widget.booking.id));
          ref.invalidate(myBookingsProvider);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  BookingConfirmationScreen(bookingId: widget.booking.id),
            ),
            (route) => false,
          );
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment verification failed on the server'),
              ),
            );
          }
        }
      } on StripeException catch (e) {
        if (mounted) {
          // Check if user cancelled
          if (e.error.code == FailureCode.Canceled) {
            debugPrint('Payment Sheet cancelled by user');
          } else {
            debugPrint(e.error.localizedMessage);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Stripe Payment Failed: ${e.error.localizedMessage}',
                ),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An unexpected payment error occurred: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFFE85D04);
    final paymentState = ref.watch(paymentControllerProvider);

    final summaryAsync = ref.watch(
      paymentSummaryProvider('${widget.booking.id}|${_appliedCoupon ?? ""}'),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'PAYMENT SUMMARY',
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
      body: Stack(
        children: [
          SafeArea(
            child: summaryAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFFE85D04)),
              ),
              error: (err, _) => Center(
                child: Text(
                  'Failed to load summary: $err',
                  style: GoogleFonts.barlow(color: Colors.red),
                ),
              ),
              data: (summary) {
                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Booking item info card
                            _buildBookingDetailsCard(isDark, primaryColor),
                            const SizedBox(height: 24),

                            // Coupon selection text field
                            _buildCouponSection(isDark, primaryColor),
                            const SizedBox(height: 24),

                            // Price breakdown receipt
                            _buildInvoiceCard(summary, isDark),
                            const SizedBox(height: 24),

                            // Choose Payment Method
                            _buildPaymentMethodSelector(isDark, primaryColor),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),

                    // Proceed to checkout button
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: ElevatedButton(
                        onPressed: paymentState.isLoading
                            ? null
                            : () => _processPayment(summary.total),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27),
                          ),
                        ),
                        child: Text(
                          _paymentMethod == 'wallet'
                              ? 'PAY VIA WALLET (\$${summary.total.toStringAsFixed(2)})'
                              : 'PAY WITH CARD (\$${summary.total.toStringAsFixed(2)})',
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

          if (paymentState.isLoading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFE85D04)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBookingDetailsCard(bool isDark, Color primaryColor) {
    return Container(
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.event_note_rounded,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.booking.service.name,
                      style: GoogleFonts.barlow(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${widget.booking.vet.name} • ${widget.booking.vet.clinicName}',
                      style: GoogleFonts.barlow(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 0.8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSmallDetail('PET', widget.booking.pet.name),
              _buildSmallDetail(
                'DATE',
                DateFormat('dd MMM yyyy').format(widget.booking.bookingDate),
              ),
              _buildSmallDetail('TIME', widget.booking.bookingTime),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.barlow(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.barlow(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildCouponSection(bool isDark, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PROMO CODE',
          style: GoogleFonts.barlow(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Colors.grey,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _couponController,
                enabled: _appliedCoupon == null,
                style: GoogleFonts.barlow(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter coupon code (e.g. SAVE20)',
                  hintStyle: GoogleFonts.barlow(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF232323) : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: isDark
                        ? BorderSide.none
                        : BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: isDark
                        ? BorderSide.none
                        : BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFFE85D04),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _appliedCoupon != null
                    ? () {
                        setState(() {
                          _appliedCoupon = null;
                          _couponController.clear();
                          _couponSuccessMessage = null;
                          _couponError = null;
                        });
                        ref.invalidate(
                          paymentSummaryProvider('${widget.booking.id}|'),
                        );
                      }
                    : _applyCouponCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _appliedCoupon != null
                      ? Colors.red
                      : primaryColor,
                  minimumSize: const Size(
                    80,
                    48,
                  ), // Override global infinite width theme
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                child: _isCouponLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _appliedCoupon != null ? 'REMOVE' : 'APPLY',
                        style: GoogleFonts.barlow(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
              ),
            ),
          ],
        ),
        if (_couponError != null) ...[
          const SizedBox(height: 6),
          Text(
            _couponError!,
            style: GoogleFonts.barlow(
              color: Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        if (_couponSuccessMessage != null) ...[
          const SizedBox(height: 6),
          Text(
            _couponSuccessMessage!,
            style: GoogleFonts.barlow(
              color: Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInvoiceCard(PaymentSummaryModel summary, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Text(
            'INVOICE DETAILS',
            style: GoogleFonts.barlow(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.grey,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          _buildInvoiceRow(
            'Service Fee',
            '\$${summary.servicePrice.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 10),
          _buildInvoiceRow(
            'Platform Fee',
            '\$${summary.platformFee.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 10),
          _buildInvoiceRow(
            'Tax ${summary.taxRate != null ? "(${summary.taxRate})" : ""}',
            '\$${summary.tax.toStringAsFixed(2)}',
          ),
          if (summary.discount > 0) ...[
            const SizedBox(height: 10),
            _buildInvoiceRow(
              'Discount',
              '-\$${summary.discount.toStringAsFixed(2)}',
              valueColor: Colors.green,
            ),
          ],
          const Divider(height: 30, thickness: 0.8),
          _buildInvoiceRow(
            'Total Amount',
            '\$${summary.total.toStringAsFixed(2)}',
            isTotal: true,
          ),
          const SizedBox(height: 6),
          _buildInvoiceRow(
            'Points Earned',
            '${summary.pawPoints} pts',
            isPoints: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceRow(
    String label,
    String value, {
    bool isTotal = false,
    bool isPoints = false,
    Color? valueColor,
  }) {
    final style = GoogleFonts.barlow(
      fontSize: isTotal ? 16 : (isPoints ? 12 : 14),
      fontWeight: isTotal
          ? FontWeight.w800
          : (isPoints ? FontWeight.w600 : FontWeight.w500),
      color: isTotal ? null : (isPoints ? Colors.orange : Colors.grey),
    );

    final valueStyle = GoogleFonts.barlow(
      fontSize: isTotal ? 18 : (isPoints ? 13 : 14),
      fontWeight: isTotal || isPoints ? FontWeight.w800 : FontWeight.w700,
      color:
          valueColor ??
          (isTotal
              ? const Color(0xFFE85D04)
              : (isPoints ? Colors.orange : null)),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: valueStyle),
      ],
    );
  }

  Widget _buildPaymentMethodSelector(bool isDark, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PAYMENT METHOD',
          style: GoogleFonts.barlow(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Colors.grey,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 12),

        // Wallet Radio
        _buildPaymentMethodTile(
          method: 'wallet',
          title: 'Wallet Payment',
          subtitle: 'Pay directly using your Pawffy credits',
          icon: Icons.account_balance_wallet_rounded,
          isDark: isDark,
          primaryColor: primaryColor,
        ),
        const SizedBox(height: 10),

        // Card Radio
        _buildPaymentMethodTile(
          method: 'card',
          title: 'Credit / Debit Card',
          subtitle: 'Secure transaction powered by Stripe',
          icon: Icons.credit_card_rounded,
          isDark: isDark,
          primaryColor: primaryColor,
        ),
      ],
    );
  }

  Widget _buildPaymentMethodTile({
    required String method,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDark,
    required Color primaryColor,
  }) {
    final isSelected = _paymentMethod == method;

    return InkWell(
      onTap: () {
        setState(() {
          _paymentMethod = method;
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
              color: Colors.black.withOpacity(0.01),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected ? primaryColor : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 14),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: primaryColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.barlow(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.barlow(fontSize: 11, color: Colors.grey),
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
