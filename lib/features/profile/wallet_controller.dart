import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'wallet_service.dart';

final walletServiceProvider = Provider<WalletService>((ref) => WalletService());

class WalletController extends AsyncNotifier<WalletModel> {
  @override
  Future<WalletModel> build() async {
    final service = ref.watch(walletServiceProvider);
    return await service.getWallet();
  }

  Future<bool> topUpWallet({required double amount}) async {
    try {
      final service = ref.read(walletServiceProvider);

      // 1. Create Top Up intent
      final data = await service.createTopUpIntent(amount);

      final paymentIntentId = data['paymentIntentId'] as String?;
      final clientSecret = data['clientSecret'] as String?;
      final ephemeralKey = data['ephemeralKey'] as String?;
      final customerId = data['customerId'] as String?;

      if (paymentIntentId == null || clientSecret == null) {
        throw Exception('Top Up Intent creation failed: missing clientSecret or paymentIntentId');
      }

      // 2. Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          customerEphemeralKeySecret: ephemeralKey,
          customerId: customerId,
          merchantDisplayName: 'Pawffy Pet Care',
          style: ThemeMode.system,
        ),
      );

      // 3. Present Stripe sheet
      await Stripe.instance.presentPaymentSheet();

      // 4. Verify payment with our backend
      await service.verifyTopUp(paymentIntentId);

      // Refresh wallet state
      ref.invalidateSelf();
      return true;
    } catch (e) {
      // Stripe cancels throw Exception on user dismissal, catch it silently or log
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> withdrawWallet({required double amount}) async {
    state = const AsyncLoading();
    try {
      final service = ref.read(walletServiceProvider);
      await service.withdraw(amount);
      ref.invalidateSelf();
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }
}

final walletControllerProvider = AsyncNotifierProvider<WalletController, WalletModel>(
  WalletController.new,
);
