import 'package:dio/dio.dart';
import 'package:pawffy/core/networks/dio_client.dart';
import 'package:pawffy/core/networks/api_constants.dart';
import '../models/vendor_model.dart';

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
}

