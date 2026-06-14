import 'package:dio/dio.dart';
import 'package:pawffy/core/networks/dio_client.dart';
import 'package:pawffy/core/networks/api_constants.dart';
import 'package:pawffy/core/storage/storage_service.dart';
import '../models/vet_model.dart';

class VetService {
  final Dio _dio = DioClient.dio;

  Future<List<VetModel>> getAllVets() async {
    try {
      final token = await StorageService.getToken();

      final response = await _dio.get(
        ApiConstants.vets,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List<dynamic> data = response.data['data'];
      return data.map((json) => VetModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch vets');
    }
  }
}
