import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:pawffy/core/networks/dio_client.dart';
import 'package:pawffy/core/networks/api_constants.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio = DioClient.dio;

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Login failed');
    }
  }

  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {'name': name, 'email': email, 'password': password},
      );

      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Registration failed');
    }
  }

  Future<UserModel> getMe(String token) async {
    try {
      final response = await _dio.get(
        ApiConstants.me,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return UserModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch profile');
    }
  }

  Future<UserModel> updateProfile({
    String? name,
    required String phone,
    required String city,
    required String state,
    required String address,
    required String token,
  }) async {
    try {
      final data = <String, dynamic>{
        'phone': phone,
        'city': city,
        'state': state,
        'address': address,
      };
      if (name != null && name.isNotEmpty) {
        data['name'] = name;
      }

      final response = await _dio.put(
        ApiConstants.updateMe,
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      debugPrint('[AuthService] updateProfile raw response: ${response.data}');

      return UserModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint(
        '[AuthService] updateProfile error response: ${e.response?.data}',
      );
      throw Exception(
        e.response?.data['message'] ?? 'Failed to update profile',
      );
    }
  }

  Future<UserModel> uploadAvatar({
    required String filePath,
    required String token,
  }) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      });

      final response = await _dio.post(
        ApiConstants.uploadAvatar,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return UserModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to upload avatar');
    }
  }

  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.changePassword,
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.data['data']['token'] as String;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to change password',
      );
    }
  }

  Future<String> forgotPassword({required String email}) async {
    try {
      final response = await _dio.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
      );
      return response.data['message'] as String? ?? 'Password reset link sent to your email';
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Forgot password failed');
    }
  }

  Future<void> logout(String token) async {
    try {
      await _dio.post(
        ApiConstants.logout,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Logout failed');
    }
  }

  Future<void> sendOtp({required String phone}) async {
    try {
      await _dio.post(
        '${ApiConstants.supabaseUrl}/auth/v1/otp',
        data: {'phone': phone},
        options: Options(headers: {
          'apikey': ApiConstants.supabaseAnonKey,
          'Authorization': 'Bearer ${ApiConstants.supabaseAnonKey}',
          'Content-Type': 'application/json',
        }),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['msg'] ??
            e.response?.data['error_description'] ??
            'Failed to send OTP. Please check phone number.',
      );
    }
  }

  Future<String> verifyOtp({
    required String phone,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.supabaseUrl}/auth/v1/verify',
        data: {
          'type': 'sms',
          'phone': phone,
          'token': token,
        },
        options: Options(headers: {
          'apikey': ApiConstants.supabaseAnonKey,
          'Authorization': 'Bearer ${ApiConstants.supabaseAnonKey}',
          'Content-Type': 'application/json',
        }),
      );

      final accessToken = response.data['access_token'] as String?;
      if (accessToken == null) {
        throw Exception('OTP Verification failed: Access Token not returned');
      }
      return accessToken;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['msg'] ??
            e.response?.data['error_description'] ??
            'OTP Verification failed. Please check the code.',
      );
    }
  }

  Future<AuthResponseModel> loginWithOtpSession({
    required String accessToken,
    String? name,
    String? email,
  }) async {
    try {
      final data = <String, dynamic>{'accessToken': accessToken};
      if (name != null && name.isNotEmpty) {
        data['name'] = name;
      }
      if (email != null && email.isNotEmpty) {
        data['email'] = email;
      }

      final response = await _dio.post(
        ApiConstants.session,
        data: data,
      );

      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ??
            'Failed to complete session authentication',
      );
    }
  }
}
