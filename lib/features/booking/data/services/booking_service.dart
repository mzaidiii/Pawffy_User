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

  // STEP 2 — Get Available Time Slots dynamically from production slots endpoint
  Future<List<String>> getAvailableSlots(String vetId, String date) async {
    try {
      final response = await _dio.get(
        ApiConstants.vetSlots(vetId),
        queryParameters: {'date': date},
        options: (await _authHeader).copyWith(
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );
      debugPrint('SLOTS API RESPONSE: ${response.data}');

      final List<dynamic> slotsData = response.data['data'] ?? [];
      final List<String> slots = [];

      for (final item in slotsData) {
        if (item is Map && item['available'] == true) {
          final String rawTime = item['time'] ?? '';
          if (rawTime.isNotEmpty) {
            try {
              final parsedTime = DateFormat('HH:mm').parse(rawTime);
              final formattedTime = DateFormat('hh:mm a').format(parsedTime);
              slots.add(formattedTime);
            } catch (e) {
              debugPrint('Error parsing slot time: $rawTime -> $e');
            }
          }
        }
      }

      return slots;
    } catch (e) {
      debugPrint('GET SLOTS ERROR: $e');
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
