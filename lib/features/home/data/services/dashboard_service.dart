import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pawffy/core/networks/dio_client.dart';
import 'package:pawffy/core/networks/api_constants.dart';
import 'package:pawffy/core/storage/storage_service.dart';
import 'package:pawffy/features/vendors/data/models/vendor_model.dart';

class DashboardService {
  final Dio _dio = DioClient.dio;

  Future<Options> get _authHeader async {
    final token = await StorageService.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  /// Get Dashboard Banners
  Future<String?> getBannerImage() async {
    try {
      final response = await _dio.get(
        ApiConstants.dashboardBanner,
        queryParameters: {'platform': 'app'},
      );
      debugPrint('BANNER API RESPONSE: ${response.data}');
      final data = response.data['data'];
      if (data is Map) {
        return data['imageUrl'] ?? data['image'] ?? data['url'] ?? data['bannerUrl'];
      } else if (data is List && data.isNotEmpty) {
        final first = data.first;
        if (first is Map) {
          return first['imageUrl'] ?? first['image'] ?? first['url'] ?? first['bannerUrl'];
        }
      } else if (data is String) {
        return data;
      }
      return null;
    } catch (e) {
      debugPrint('GET BANNER ERROR: $e');
      return null;
    }
  }

  /// Get Nearby Partners using POST /api/dashboard/partners
  Future<List<VendorModel>> getNearbyPartners({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.dashboardPartners,
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
        options: await _authHeader,
      );
      debugPrint('NEARBY PARTNERS RESPONSE: ${response.data}');
      final List<dynamic> data = response.data['data'] is List
          ? response.data['data']
          : [];
      return data
          .map((json) => VendorModel.fromJson(json))
          .where((vet) => vet.isVerified)
          .toList();
    } catch (e) {
      debugPrint('GET NEARBY PARTNERS ERROR: $e');
      return [];
    }
  }
}
