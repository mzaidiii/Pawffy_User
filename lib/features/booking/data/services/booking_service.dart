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
  Future<List<String>> getAvailableSlots(
    String vendorId,
    String date, {
    String? serviceId,
    String? serviceType,
  }) async {
    try {
      // 1. Fetch vendor details
      final response = await _dio.get(
        ApiConstants.vendorById(vendorId),
        options: await _authHeader,
      );
      final vendorData = response.data['data'] ?? {};
      
      // 2. Determine target day of week from date (date is formatted as "yyyy-MM-dd")
      final parsedDate = DateFormat('yyyy-MM-dd').parse(date);
      final String dayOfWeek = DateFormat('E').format(parsedDate); // e.g. "Wed", "Thu", "Mon"
      
      // 3. Find availability for this day of week
      final List<dynamic> availabilityList = vendorData['availability'] is List
          ? vendorData['availability']
          : [];
          
      Map<String, dynamic>? todayAvailability;
      for (final item in availabilityList) {
        if (item is Map && item['dayOfWeek']?.toString().toLowerCase().trim() == dayOfWeek.toLowerCase().trim()) {
          todayAvailability = Map<String, dynamic>.from(item);
          break;
        }
      }
      
      // Also check timings workingDays
      final timings = vendorData['timings'] is Map ? vendorData['timings'] : null;
      final List<dynamic> workingDays = timings != null && timings['workingDays'] is List
          ? timings['workingDays']
          : [];
          
      final bool isWorkingDay = todayAvailability != null 
          ? (todayAvailability['isAvailable'] == true)
          : workingDays.any((d) => d.toString().toLowerCase().trim() == dayOfWeek.toLowerCase().trim());
          
      if (!isWorkingDay) {
        debugPrint('Vendor is not available on $dayOfWeek ($date)');
        return []; // Not available on this day
      }
      
      // Get start/end time
      String startTimeStr = todayAvailability?['startTime'] ?? timings?['startTime'] ?? '09:00 AM';
      String endTimeStr = todayAvailability?['endTime'] ?? timings?['endTime'] ?? '06:00 PM';
      
      // Generate slots dynamically between startTime and endTime
      return _generateSlots(startTimeStr, endTimeStr);
    } catch (e) {
      debugPrint('DYNAMIC SLOTS GENERATION FAILED: $e');
      return [];
    }
  }

  List<String> _generateSlots(String startTimeStr, String endTimeStr) {
    final List<String> slots = [];
    try {
      final DateFormat parser = DateFormat('hh:mm a');
      final DateTime start = _parseTime(startTimeStr);
      final DateTime end = _parseTime(endTimeStr);
      
      DateTime current = start;
      while (current.isBefore(end)) {
        slots.add(parser.format(current));
        current = current.add(const Duration(minutes: 60)); // Hourly slots
      }
    } catch (e) {
      debugPrint('Error parsing/generating slots from timings: $e');
      // Fallback: standard business hours
      return ['09:00 AM', '10:00 AM', '11:00 AM', '12:00 PM', '01:00 PM', '02:00 PM', '03:00 PM', '04:00 PM', '05:00 PM'];
    }
    return slots;
  }

  DateTime _parseTime(String timeStr) {
    try {
      return DateFormat('hh:mm a').parse(timeStr.trim());
    } catch (_) {
      try {
        return DateFormat('HH:mm').parse(timeStr.trim());
      } catch (_) {
        return DateFormat('yyyy-MM-dd HH:mm').parse('2000-01-01 ${timeStr.trim()}');
      }
    }
  }

  Future<List<VendorServiceModel>> getVendorServices(String vendorId) async {
    try {
      final response = await _dio.get(
        ApiConstants.vendorById(vendorId),
        options: await _authHeader,
      );
      final vendorData = response.data['data'] ?? {};
      final List<dynamic> servicesData = vendorData['services'] ?? [];
      return servicesData.map((json) => VendorServiceModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('FETCH VENDOR SERVICES FAILED: $e');
      throw Exception('Failed to fetch services');
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

  // POST /api/bookings/walking
  Future<BookingModel> createWalkingBooking(Map<String, dynamic> walkingData) async {
    try {
      final response = await _dio.post(
        ApiConstants.walkingBookings,
        data: walkingData,
        options: await _authHeader,
      );
      return BookingModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('CREATE WALKING BOOKING ERROR: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to create walking booking',
      );
    }
  }

  // GET /api/bookings/walking
  Future<List<BookingModel>> getMyWalkingBookings() async {
    try {
      final response = await _dio.get(
        ApiConstants.walkingBookings,
        options: await _authHeader,
      );
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => BookingModel.fromJson(json)).toList();
    } on DioException catch (e) {
      debugPrint('GET WALKING BOOKINGS ERROR: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch walking bookings',
      );
    }
  }
}
