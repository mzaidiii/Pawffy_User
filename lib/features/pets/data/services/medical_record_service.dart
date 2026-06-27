import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pawffy/core/networks/dio_client.dart';
import 'package:pawffy/core/networks/api_constants.dart';
import 'package:pawffy/core/storage/storage_service.dart';
import '../models/medical_record_model.dart';

class MedicalRecordService {
  final Dio _dio = DioClient.dio;

  Future<Options> get _authHeader async {
    final token = await StorageService.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  // GET /api/medical-records/pet/:petId
  Future<List<MedicalRecordModel>> getMedicalRecordsForPet(String petId) async {
    try {
      final response = await _dio.get(
        ApiConstants.medicalRecordsByPet(petId),
        options: await _authHeader,
      );
      final List<dynamic> data = response.data['data'];
      return data.map((json) => MedicalRecordModel.fromJson(json)).toList();
    } on DioException catch (e) {
      debugPrint('GET MEDICAL RECORDS ERROR: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch medical records',
      );
    }
  }

  // GET /api/medical-records/:id
  Future<MedicalRecordModel> getMedicalRecordById(String id) async {
    try {
      final response = await _dio.get(
        ApiConstants.medicalRecordById(id),
        options: await _authHeader,
      );
      return MedicalRecordModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('GET MEDICAL RECORD BY ID ERROR: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch medical record details',
      );
    }
  }

  // POST /api/medical-records
  Future<MedicalRecordModel> createMedicalRecord(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post(
        ApiConstants.medicalRecords,
        data: body,
        options: await _authHeader,
      );
      return MedicalRecordModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('CREATE MEDICAL RECORD ERROR: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to create medical record',
      );
    }
  }

  // PUT /api/medical-records/:id
  Future<MedicalRecordModel> updateMedicalRecord(
    String id,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.put(
        ApiConstants.medicalRecordById(id),
        data: body,
        options: await _authHeader,
      );
      // Backend returns only updated fields + id, so we merge it locally in the controller
      return MedicalRecordModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('UPDATE MEDICAL RECORD ERROR: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to update medical record',
      );
    }
  }

  // DELETE /api/medical-records/:id
  Future<void> deleteMedicalRecord(String id) async {
    try {
      await _dio.delete(
        ApiConstants.medicalRecordById(id),
        options: await _authHeader,
      );
    } on DioException catch (e) {
      debugPrint('DELETE MEDICAL RECORD ERROR: ${e.response?.data}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to delete medical record',
      );
    }
  }
}
