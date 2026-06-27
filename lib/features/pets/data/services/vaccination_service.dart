import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pawffy/core/networks/dio_client.dart';
import 'package:pawffy/core/networks/api_constants.dart';
import 'package:pawffy/core/storage/storage_service.dart';
import '../models/vaccination_model.dart';

class VaccinationService {
  final Dio _dio = DioClient.dio;

  Future<Options> get _authHeader async {
    final token = await StorageService.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  // GET /api/vaccinations/pet/:petId
  Future<List<VaccinationModel>> getVaccinationsForPet(String petId) async {
    try {
      final response = await _dio.get(
        ApiConstants.vaccinationsByPet(petId),
        options: await _authHeader,
      );
      final List<dynamic> data = response.data['data'];
      return data.map((json) => VaccinationModel.fromJson(json)).toList();
    } on DioException catch (e) {
      debugPrint('GET VACCINATIONS ERROR: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch vaccination records',
      );
    }
  }

  // POST /api/vaccinations
  Future<VaccinationModel> addVaccination(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post(
        ApiConstants.vaccinations,
        data: body,
        options: await _authHeader,
      );
      return VaccinationModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('ADD VACCINATION ERROR: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to add vaccination record',
      );
    }
  }

  // PUT /api/vaccinations/:id
  Future<VaccinationModel> updateVaccination(
    String id,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.put(
        ApiConstants.vaccinationById(id),
        data: body,
        options: await _authHeader,
      );
      return VaccinationModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('UPDATE VACCINATION ERROR: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to update vaccination record',
      );
    }
  }

  // DELETE /api/vaccinations/:id
  Future<void> deleteVaccination(String id) async {
    try {
      await _dio.delete(
        ApiConstants.vaccinationById(id),
        options: await _authHeader,
      );
    } on DioException catch (e) {
      debugPrint('DELETE VACCINATION ERROR: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to delete vaccination record',
      );
    }
  }
}
