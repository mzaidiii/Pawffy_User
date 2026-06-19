import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pawffy/core/networks/dio_client.dart';
import 'package:pawffy/core/networks/api_constants.dart';
import 'package:pawffy/core/storage/storage_service.dart';
import '../models/pet_model.dart';

class PetService {
  final Dio _dio = DioClient.dio;

  Future<Options> get _authHeader async {
    final token = await StorageService.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  // GET /api/pets
  Future<List<PetModel>> getMyPets() async {
    try {
      final response = await _dio.get(
        ApiConstants.pets,
        options: await _authHeader,
      );
      final List<dynamic> data = response.data['data'];
      return data.map((json) => PetModel.fromJson(json)).toList();
    } on DioException catch (e) {
      debugPrint('GET PETS ERROR: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch pets');
    }
  }

  // GET /api/pets/:petId
  Future<PetModel> getPetById(String petId) async {
    try {
      final response = await _dio.get(
        ApiConstants.petById(petId),
        options: await _authHeader,
      );
      return PetModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('GET PET ERROR: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch pet');
    }
  }

  // POST /api/pets
  Future<PetModel> createPet(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post(
        ApiConstants.pets,
        data: body,
        options: await _authHeader,
      );
      return PetModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('CREATE PET ERROR: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Failed to create pet');
    }
  }

  // PUT /api/pets/:petId
  Future<PetModel> updatePet(String petId, Map<String, dynamic> body) async {
    try {
      final response = await _dio.put(
        ApiConstants.petById(petId),
        data: body,
        options: await _authHeader,
      );
      return PetModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('UPDATE PET ERROR: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Failed to update pet');
    }
  }

  // DELETE /api/pets/:petId
  Future<void> deletePet(String petId) async {
    try {
      await _dio.delete(
        ApiConstants.petById(petId),
        options: await _authHeader,
      );
    } on DioException catch (e) {
      debugPrint('DELETE PET ERROR: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Failed to delete pet');
    }
  }

  // POST /api/pets/:petId/image
  Future<PetModel> uploadPetImage(String petId, String filePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      });

      final authOpts = await _authHeader;
      final Map<String, dynamic> headers = Map<String, dynamic>.from(authOpts.headers ?? {});
      headers['Content-Type'] = 'multipart/form-data';

      final response = await _dio.post(
        ApiConstants.uploadPetImage(petId),
        data: formData,
        options: Options(headers: headers),
      );

      return PetModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('UPLOAD PET IMAGE ERROR: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to upload pet image',
      );
    }
  }
}
