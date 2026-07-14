import 'package:dio/dio.dart';
import 'package:pawffy/core/networks/dio_client.dart';
import 'package:pawffy/core/networks/api_constants.dart';
import 'package:pawffy/core/storage/storage_service.dart';

class WalletTransactionModel {
  final String id;
  final String description;
  final String type; // credit / debit
  final double amount;
  final String status;
  final String date;

  WalletTransactionModel({
    required this.id,
    required this.description,
    required this.type,
    required this.amount,
    required this.status,
    required this.date,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      description: json['description'] ?? json['type'] ?? 'Transaction',
      type: json['type']?.toString().toLowerCase() ?? 'debit',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'completed',
      date: json['createdAt'] ?? json['date'] ?? '',
    );
  }
}

class WalletModel {
  final double balance;
  final List<WalletTransactionModel> transactions;

  WalletModel({
    required this.balance,
    required this.transactions,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    final balanceVal = (json['balance'] as num?)?.toDouble() ?? 0.0;
    final List<dynamic> txs = json['transactions'] ?? [];
    return WalletModel(
      balance: balanceVal,
      transactions: txs.map((tx) => WalletTransactionModel.fromJson(tx)).toList(),
    );
  }
}

class WalletService {
  final Dio _dio = DioClient.dio;

  Future<WalletModel> getWallet() async {
    try {
      final token = await StorageService.getToken();
      final response = await _dio.get(
        ApiConstants.wallet,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final data = response.data['data'] ?? response.data;
      return WalletModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load wallet');
    }
  }

  Future<Map<String, dynamic>> createTopUpIntent(double amount) async {
    try {
      final token = await StorageService.getToken();
      final response = await _dio.post(
        ApiConstants.walletTopUpIntent,
        data: {'amount': amount},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data['data'] ?? response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to prepare Top Up');
    }
  }

  Future<void> verifyTopUp(String paymentIntentId) async {
    try {
      final token = await StorageService.getToken();
      await _dio.post(
        ApiConstants.walletTopUpVerify,
        data: {'paymentIntentId': paymentIntentId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to verify Top Up');
    }
  }

  Future<void> withdraw(double amount) async {
    try {
      final token = await StorageService.getToken();
      await _dio.post(
        ApiConstants.walletWithdraw,
        data: {'amount': amount},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to process withdrawal');
    }
  }
}
