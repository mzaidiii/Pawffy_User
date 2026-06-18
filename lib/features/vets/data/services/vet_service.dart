import 'package:dio/dio.dart';
import 'package:pawffy/core/networks/dio_client.dart';
import 'package:pawffy/core/networks/api_constants.dart';
import 'package:pawffy/core/storage/storage_service.dart';
import '../models/vet_model.dart';

class VetService {
  final Dio _dio = DioClient.dio;

  Future<Options> _authOptions() async {
    final token = await StorageService.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<List<VetModel>> getAllVets() async {
    try {
      final response = await _dio.get(
        ApiConstants.vets,
        options: await _authOptions(),
      );
      final List<dynamic> data = response.data['data'];
      return data.map((json) => VetModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch vets');
    }
  }

  Future<List<VetModel>> getVetsByServiceType({
    String? serviceType,
    String? search,
    String? city,
  }) async {
    try {
      final Map<String, dynamic> params = {
        if (serviceType != null && serviceType.isNotEmpty)
          'serviceType': serviceType,
        if (search != null && search.isNotEmpty) 'search': search,
        if (city != null && city.isNotEmpty) 'city': city,
      };
      final response = await _dio.get(
        ApiConstants.vets,
        queryParameters: params,
        options: await _authOptions(),
      );
      final List<dynamic> data = response.data['data'];
      return data.map((json) => VetModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch providers',
      );
    }
  }

  Future<VetModel> getVetById(String vetId) async {
    try {
      final response = await _dio.get(
        ApiConstants.vetById(vetId),
        options: await _authOptions(),
      );
      return VetModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch provider details',
      );
    }
  }
}
