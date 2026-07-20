import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pawffy/core/networks/dio_client.dart';
import 'package:pawffy/core/networks/api_constants.dart';
import 'package:pawffy/core/storage/storage_service.dart';

final supportServiceProvider = Provider<SupportService>((ref) => SupportService());

class SupportService {
  final Dio _dio = DioClient.dio;

  Future<void> createSupportTicket({
    required String subject,
    required String category,
    required String description,
    String? attachmentPath,
  }) async {
    try {
      final token = await StorageService.getToken();
      final Map<String, dynamic> dataMap = {
        'subject': subject,
        'category': category,
        'description': description,
      };

      if (attachmentPath != null && attachmentPath.isNotEmpty) {
        dataMap['attachment'] = await MultipartFile.fromFile(
          attachmentPath,
          filename: attachmentPath.split('/').last,
        );
      }

      final formData = FormData.fromMap(dataMap);

      await _dio.post(
        ApiConstants.supportTickets,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to submit support ticket');
    }
  }

  Future<String> getPrivacy() async {
    try {
      final response = await _dio.get(ApiConstants.staticPrivacy);
      final data = response.data['data'] ?? response.data;
      if (data is Map) {
        return data['content']?.toString() ?? '';
      }
      return data?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<String> getTerms() async {
    try {
      final response = await _dio.get(ApiConstants.staticTerms);
      final data = response.data['data'] ?? response.data;
      if (data is Map) {
        return data['content']?.toString() ?? '';
      }
      return data?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<void> deleteAccount() async {
    try {
      final token = await StorageService.getToken();
      await _dio.delete(
        ApiConstants.deleteMyAccount,
        data: const {'confirm': 'DELETE'},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to delete account');
    }
  }
}
