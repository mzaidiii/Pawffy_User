import 'package:dio/dio.dart';
import 'package:pawffy/core/networks/dio_client.dart';
import 'package:pawffy/core/networks/api_constants.dart';
import 'package:pawffy/core/storage/storage_service.dart';
import 'address_provider.dart';

class AddressService {
  final Dio _dio = DioClient.dio;

  Future<List<AddressModel>> getAddresses() async {
    try {
      final token = await StorageService.getToken();
      final response = await _dio.get(
        ApiConstants.addresses,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List<dynamic> dataList = response.data['data'] ?? [];
      return dataList.map((item) {
        return AddressModel(
          id: item['id']?.toString() ?? item['_id']?.toString() ?? '',
          label: item['label'] ?? 'Other',
          fullName: '',
          mobile: '',
          addressLine1: item['address'] ?? '',
          city: item['city'] ?? '',
          state: item['state'] ?? '',
          pinCode: item['pincode']?.toString() ?? '',
          isDefault: item['isDefault'] ?? false,
        );
      }).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load addresses');
    }
  }

  Future<AddressModel> createAddress({
    required String label,
    required String address,
    required String city,
    required String state,
    required String pincode,
    required bool isDefault,
  }) async {
    try {
      final token = await StorageService.getToken();
      final response = await _dio.post(
        ApiConstants.addresses,
        data: {
          'label': label,
          'address': address,
          'city': city,
          'state': state,
          'pincode': pincode,
          'isDefault': isDefault,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final item = response.data['data'];
      return AddressModel(
        id: item['id']?.toString() ?? item['_id']?.toString() ?? '',
        label: item['label'] ?? 'Other',
        fullName: '',
        mobile: '',
        addressLine1: item['address'] ?? '',
        city: item['city'] ?? '',
        state: item['state'] ?? '',
        pinCode: item['pincode']?.toString() ?? '',
        isDefault: item['isDefault'] ?? false,
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to create address');
    }
  }

  Future<AddressModel> updateAddress({
    required String id,
    required String label,
    required String address,
    required String city,
    required String state,
  }) async {
    try {
      final token = await StorageService.getToken();
      final response = await _dio.put(
        ApiConstants.addressById(id),
        data: {
          'label': label,
          'address': address,
          'city': city,
          'state': state,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final item = response.data['data'];
      return AddressModel(
        id: item['id']?.toString() ?? item['_id']?.toString() ?? '',
        label: item['label'] ?? 'Other',
        fullName: '',
        mobile: '',
        addressLine1: item['address'] ?? '',
        city: item['city'] ?? '',
        state: item['state'] ?? '',
        pinCode: item['pincode']?.toString() ?? '',
        isDefault: item['isDefault'] ?? false,
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to update address');
    }
  }

  Future<void> setDefaultAddress(String id) async {
    try {
      final token = await StorageService.getToken();
      await _dio.patch(
        ApiConstants.setDefaultAddress(id),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to set default address');
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      final token = await StorageService.getToken();
      await _dio.delete(
        ApiConstants.addressById(id),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to delete address');
    }
  }
}
