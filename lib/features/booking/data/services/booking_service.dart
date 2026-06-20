import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pawffy/core/networks/dio_client.dart';
import 'package:pawffy/core/networks/api_constants.dart';
import 'package:pawffy/core/storage/storage_service.dart';
import '../models/booking_model.dart';

class BookingService {
  final Dio _dio = DioClient.dio;

  Future<Options> get _authHeader async {
    final token = await StorageService.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  // STEP 2 — Get Available Time Slots dynamically from availability schedule
  Future<List<String>> getAvailableSlots(String vetId, String date) async {
    try {
      final response = await _dio.get(
        ApiConstants.vetAvailability(vetId),
        options: (await _authHeader).copyWith(
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
        ),
      );
      debugPrint('SLOTS API RESPONSE: ${response.data}');

      final List<dynamic> availabilities = response.data['data'] ?? [];
      
      // Find the weekday of the selected date (e.g., "Monday", "Friday")
      final selectedDateTime = DateTime.parse(date);
      final weekdayName = DateFormat('EEEE').format(selectedDateTime); // e.g. "Friday"

      // Find availability for this weekday
      final availability = availabilities.firstWhere(
        (a) => a is Map &&
               a['dayOfWeek']?.toString().toLowerCase() == weekdayName.toLowerCase() &&
               a['isAvailable'] == true,
        orElse: () => null,
      );

      if (availability == null) {
        debugPrint('No availability found for $weekdayName');
        return [];
      }

      final String startTime = availability['startTime'] ?? '09:00';
      final String endTime = availability['endTime'] ?? '17:00';
      final int duration = availability['slotDuration'] ?? 30;

      // Generate slots list dynamically from start to end time
      final startParts = startTime.split(':');
      final startHour = int.parse(startParts[0]);
      final startMinute = int.parse(startParts[1]);

      final endParts = endTime.split(':');
      final endHour = int.parse(endParts[0]);
      final endMinute = int.parse(endParts[1]);

      final List<String> slots = [];
      var current = DateTime(2000, 1, 1, startHour, startMinute);
      final end = DateTime(2000, 1, 1, endHour, endMinute);

      while (current.isBefore(end)) {
        final formattedTime = DateFormat('hh:mm a').format(current); // e.g., "09:00 AM"
        slots.add(formattedTime);
        current = current.add(Duration(minutes: duration));
      }

      return slots;
    } catch (e) {
      debugPrint('GET SLOTS ERROR (Gracefully catching and returning empty): $e');
      return []; // Return empty list to show "No slots available" gracefully
    }
  }

  Future<List<VetServiceModel>> getVetServices(String vetId) async {
    try {
      final response = await _dio.get(
        ApiConstants.vetServices(vetId),
        options: await _authHeader,
      );
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => VetServiceModel.fromJson(json)).toList();
    } on DioException catch (e) {
      debugPrint('GET SERVICES ERROR: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch services',
      );
    }
  }

  Future<BookingModel> createBooking(Map<String, dynamic> bookingData) async {
    try {
      final response = await _dio.post(
        ApiConstants.bookings,
        data: bookingData,
        options: await _authHeader,
      );
      return BookingModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('CREATE BOOKING ERROR: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to create booking',
      );
    }
  }

  Future<PaymentSummaryModel> getPaymentSummary(
    String bookingId, {
    String? couponCode,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.paymentSummary(bookingId),
        queryParameters: couponCode != null ? {'coupon': couponCode} : null,
        options: await _authHeader,
      );
      return PaymentSummaryModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('GET SUMMARY ERROR: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch summary');
    }
  }

  Future<Map<String, dynamic>> applyCoupon(
    String bookingId,
    String couponCode,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.applyCoupon,
        data: {'bookingId': bookingId, 'code': couponCode},
        options: await _authHeader,
      );
      return response.data;
    } on DioException catch (e) {
      debugPrint('APPLY COUPON ERROR: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Failed to apply coupon');
    }
  }

  Future<PaymentIntentModel> createPaymentIntent(
    String bookingId,
    String paymentMethod, {
    String? couponCode,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.createPaymentIntent,
        data: {
          'bookingId': bookingId,
          'paymentMethod': paymentMethod,
          if (couponCode != null) 'couponCode': couponCode,
        },
        options: await _authHeader,
      );
      return PaymentIntentModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('CREATE INTENT ERROR: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to create payment intent',
      );
    }
  }

  Future<Map<String, dynamic>> confirmWalletPayment(
    String bookingId, {
    String? couponCode,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.confirmWalletPayment,
        data: {
          'bookingId': bookingId,
          if (couponCode != null) 'couponCode': couponCode,
        },
        options: await _authHeader,
      );
      return response.data;
    } on DioException catch (e) {
      debugPrint('CONFIRM WALLET PAYMENT ERROR: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to confirm wallet payment',
      );
    }
  }

  Future<Map<String, dynamic>> verifyPayment(String paymentIntentId) async {
    try {
      final response = await _dio.post(
        ApiConstants.verifyStripePayment,
        data: {'paymentIntentId': paymentIntentId},
        options: await _authHeader,
      );
      return response.data;
    } on DioException catch (e) {
      debugPrint('VERIFY PAYMENT ERROR: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to verify payment',
      );
    }
  }

  Future<BookingModel> getBookingDetails(String bookingId) async {
    try {
      final response = await _dio.get(
        ApiConstants.bookingById(bookingId),
        options: await _authHeader,
      );
      return BookingModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('GET BOOKING DETAILS ERROR: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch booking details',
      );
    }
  }

  // GET /api/bookings
  Future<List<BookingModel>> getMyBookings() async {
    try {
      final response = await _dio.get(
        ApiConstants.bookings,
        options: await _authHeader,
      );
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => BookingModel.fromJson(json)).toList();
    } on DioException catch (e) {
      debugPrint('GET MY BOOKINGS ERROR: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch bookings',
      );
    }
  }
}
