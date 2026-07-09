import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pawffy/core/networks/dio_client.dart';
import 'package:pawffy/core/networks/api_constants.dart';
import 'package:pawffy/core/storage/storage_service.dart';
import '../models/lost_found_model.dart';

class LostFoundService {
  final Dio _dio = DioClient.dio;

  Future<Options> get _authHeader async {
    final token = await StorageService.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  /// Create a Lost Pet Report
  Future<LostFoundReportModel> createLostReport(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        ApiConstants.lostPets,
        data: data,
        options: await _authHeader,
      );
      final reportData = response.data['data'] ?? response.data;
      return LostFoundReportModel.fromJson(reportData);
    } on DioException catch (e) {
      debugPrint('CREATE LOST REPORT ERROR: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to report lost pet',
      );
    }
  }

  /// Create a Found Pet Report
  Future<LostFoundReportModel> createFoundReport(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        ApiConstants.foundPets,
        data: data,
        options: await _authHeader,
      );
      final reportData = response.data['data'] ?? response.data;
      return LostFoundReportModel.fromJson(reportData);
    } on DioException catch (e) {
      debugPrint('CREATE FOUND REPORT ERROR: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to report found pet',
      );
    }
  }

  /// Get All Reports (Lost + Found unified feed)
  Future<List<LostFoundReportModel>> getAllReports() async {
    try {
      final response = await _dio.get(
        ApiConstants.allPetReports,
        options: await _authHeader,
      );

      final List<LostFoundReportModel> reports = [];

      if (response.data['data'] is List) {
        final List<dynamic> rawList = response.data['data'];
        for (final json in rawList) {
          if (json is Map<String, dynamic>) {
            reports.add(LostFoundReportModel.fromJson(json));
          }
        }
      } else {
        final List<dynamic> lostList = response.data['lostPets'] is List
            ? response.data['lostPets']
            : (response.data['data']?['lostPets'] is List
                ? response.data['data']['lostPets']
                : []);
        final List<dynamic> foundList = response.data['foundPets'] is List
            ? response.data['foundPets']
            : (response.data['data']?['foundPets'] is List
                ? response.data['data']['foundPets']
                : []);

        for (final json in lostList) {
          if (json is Map<String, dynamic>) {
            reports.add(LostFoundReportModel.fromJson(json));
          }
        }
        for (final json in foundList) {
          if (json is Map<String, dynamic>) {
            reports.add(LostFoundReportModel.fromJson(json));
          }
        }
      }

      // Sort reports by creation date descending (newest first)
      reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reports;
    } on DioException catch (e) {
      debugPrint('GET ALL REPORTS ERROR: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch pet reports',
      );
    }
  }

  /// Get Lost Report by ID
  Future<LostFoundReportModel> getLostReportById(String id) async {
    try {
      final response = await _dio.get(
        ApiConstants.lostPetReportById(id),
        options: await _authHeader,
      );
      final reportData = response.data['data'] ?? response.data;
      return LostFoundReportModel.fromJson(reportData);
    } on DioException catch (e) {
      debugPrint('GET LOST REPORT BY ID ERROR: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch report details',
      );
    }
  }

  /// Get Found Report by ID
  Future<LostFoundReportModel> getFoundReportById(String id) async {
    try {
      final response = await _dio.get(
        ApiConstants.foundPetById(id),
        options: await _authHeader,
      );
      final reportData = response.data['data'] ?? response.data;
      return LostFoundReportModel.fromJson(reportData);
    } on DioException catch (e) {
      debugPrint('GET FOUND REPORT BY ID ERROR: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch report details',
      );
    }
  }

  /// Delete Lost Report
  Future<void> deleteLostReport(String id) async {
    try {
      await _dio.delete(
        ApiConstants.lostPetReportById(id),
        options: await _authHeader,
      );
    } on DioException catch (e) {
      debugPrint('DELETE LOST REPORT ERROR: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to delete report',
      );
    }
  }

  /// Delete Found Report
  Future<void> deleteFoundReport(String id) async {
    try {
      await _dio.delete(
        ApiConstants.foundPetById(id),
        options: await _authHeader,
      );
    } on DioException catch (e) {
      debugPrint('DELETE FOUND REPORT ERROR: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to delete report',
      );
    }
  }
}
