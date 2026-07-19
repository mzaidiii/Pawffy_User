import 'package:dio/dio.dart';
import 'package:pawffy/core/networks/dio_client.dart';
import 'package:pawffy/core/networks/api_constants.dart';
import '../models/vendor_model.dart';
import 'package:pawffy/core/storage/storage_service.dart';

class VendorService {
  final Dio _dio = DioClient.dio;

  /// Fetch all vendors — public endpoint, no auth needed.
  /// Filters out unverified vendors.
  Future<List<VendorModel>> getAllVendors() async {
    try {
      final response = await _dio.get(ApiConstants.vendors);
      final List<dynamic> data = response.data['data'] is List
          ? response.data['data']
          : [];
      return data
          .map((json) => VendorModel.fromJson(json))
          .where((vet) => vet.isVerified)
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch vendors',
      );
    }
  }

  /// Search/filter vendors — public endpoint, no auth needed.
  /// Supports query params: serviceType, city, search.
  /// Filters out unverified vendors.
  Future<List<VendorModel>> getVendorsByServiceType({
    String? serviceType,
    String? search,
    String? city,
    bool? isOnline,
  }) async {
    try {
      final Map<String, dynamic> params = {
        if (serviceType != null && serviceType.isNotEmpty)
          'serviceType': serviceType,
        if (search != null && search.isNotEmpty) 'search': search,
        if (city != null && city.isNotEmpty) 'city': city,
        if (isOnline != null) 'isOnline': isOnline,
      };
      final response = await _dio.get(
        ApiConstants.vendors,
        queryParameters: params,
      );
      final List<dynamic> data = response.data['data'] is List
          ? response.data['data']
          : [];
      return data
          .map((json) => VendorModel.fromJson(json))
          .where((vet) => vet.isVerified)
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch vendors',
      );
    }
  }

  /// Single vendor detail.
  /// Retrieves details from /api/vendors/:id.
  Future<VendorModel?> getVendorById(String vendorId) async {
    try {
      final response = await _dio.get(ApiConstants.vendorById(vendorId));
      if (response.data['data'] != null) {
        return VendorModel.fromJson(response.data['data']);
      }
      return null;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch vendor details',
      );
    }
  }

  Future<List<VendorReview>> getReviews(String vendorId) async {
    try {
      final response = await _dio.get(
        ApiConstants.vendorReviews(vendorId),
        queryParameters: const {'page': 1, 'limit': 20},
      );
      final body = response.data['data'];
      final items = body is List ? body : (body is Map ? body['reviews'] : const []);
      return items is List
          ? items.whereType<Map>().map((item) => VendorReview.fromJson(Map<String, dynamic>.from(item))).toList()
          : [];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load reviews');
    }
  }

  Future<void> createReview({
    required String vendorId,
    required String bookingId,
    required int rating,
    required String comment,
  }) async {
    try {
      final token = await StorageService.getToken();
      await _dio.post(
        ApiConstants.vendorReviews(vendorId),
        data: {'bookingId': bookingId, 'rating': rating, 'comment': comment},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Unable to submit review');
    }
  }
}

class VendorReview {
  final String id;
  final String author;
  final int rating;
  final String comment;

  const VendorReview({required this.id, required this.author, required this.rating, required this.comment});

  factory VendorReview.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    return VendorReview(
      id: json['id']?.toString() ?? '',
      author: user is Map ? (user['name']?.toString() ?? 'Pawffy customer') : (json['userName']?.toString() ?? 'Pawffy customer'),
      rating: int.tryParse(json['rating']?.toString() ?? '') ?? 0,
      comment: json['comment']?.toString() ?? '',
    );
  }
}
