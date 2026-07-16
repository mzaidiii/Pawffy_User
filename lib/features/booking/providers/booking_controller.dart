import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/booking_model.dart';
import '../data/services/booking_service.dart';

final bookingServiceProvider = Provider<BookingService>((ref) {
  return BookingService();
});

// Fetch slots for a given vet and date
final bookingSlotsProvider = FutureProvider.family<List<String>, String>((ref, paramString) {
  final parts = paramString.split('|');
  final vetId = parts[0];
  final date = parts[1];
  final serviceId = parts.length > 2 && parts[2].isNotEmpty ? parts[2] : null;
  final serviceType = parts.length > 3 && parts[3].isNotEmpty ? parts[3] : null;
  return ref.watch(bookingServiceProvider).getAvailableSlots(
        vetId,
        date,
        serviceId: serviceId,
        serviceType: serviceType,
      );
});

// Fetch services offered by a vendor
final vendorServicesProvider = FutureProvider.family<List<VendorServiceModel>, String>((ref, vendorId) {
  return ref.watch(bookingServiceProvider).getVendorServices(vendorId);
});

// Fetch booking by ID
final bookingDetailsProvider = FutureProvider.family<BookingModel, String>((ref, bookingId) {
  return ref.watch(bookingServiceProvider).getBookingDetails(bookingId);
});

// Fetch price summary with optional coupon
final paymentSummaryProvider = FutureProvider.family<PaymentSummaryModel, String>((ref, paramString) {
  final parts = paramString.split('|');
  final bookingId = parts[0];
  final coupon = parts.length > 1 && parts[1].isNotEmpty ? parts[1] : null;
  return ref.watch(bookingServiceProvider).getPaymentSummary(bookingId, couponCode: coupon);
});

// Fetch list of user's bookings
final myBookingsProvider = FutureProvider<List<BookingModel>>((ref) {
  return ref.watch(bookingServiceProvider).getMyBookings();
});

class BookingController extends Notifier<AsyncValue<BookingModel?>> {
  @override
  AsyncValue<BookingModel?> build() {
    return const AsyncData(null);
  }

  Future<BookingModel?> createBooking(Map<String, dynamic> bookingData) async {
    state = const AsyncLoading();
    try {
      final booking = await ref.read(bookingServiceProvider).createBooking(bookingData);
      state = AsyncData(booking);
      return booking;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final bookingControllerProvider = NotifierProvider<BookingController, AsyncValue<BookingModel?>>(BookingController.new);

class PaymentController extends Notifier<AsyncValue<Map<String, dynamic>?>> {
  @override
  AsyncValue<Map<String, dynamic>?> build() {
    return const AsyncData(null);
  }

  // Direct Wallet Payment
  Future<Map<String, dynamic>> payWithWallet(String bookingId, {String? couponCode}) async {
    state = const AsyncLoading();
    try {
      final result = await ref.read(bookingServiceProvider).confirmWalletPayment(bookingId, couponCode: couponCode);
      state = AsyncData(result);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  // Create Stripe Intent
  Future<PaymentIntentModel> createStripeIntent(String bookingId, {String? couponCode}) async {
    state = const AsyncLoading();
    try {
      final intent = await ref.read(bookingServiceProvider).createPaymentIntent(bookingId, 'card', couponCode: couponCode);
      state = const AsyncData(null);
      return intent;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  // Verify Stripe Payment
  Future<Map<String, dynamic>> verifyStripePayment(String paymentIntentId) async {
    state = const AsyncLoading();
    try {
      final result = await ref.read(bookingServiceProvider).verifyPayment(paymentIntentId);
      state = AsyncData(result);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final paymentControllerProvider = NotifierProvider<PaymentController, AsyncValue<Map<String, dynamic>?>>(PaymentController.new);
