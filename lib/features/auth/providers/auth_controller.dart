import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/storage_service.dart';
import '../data/models/user_model.dart';
import 'auth_provider.dart';
import 'current_user_provider.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> login({required String email, required String password}) async {
    state = const AsyncLoading();

    try {
      final authService = ref.read(authServiceProvider);

      final response = await authService.login(
        email: email,
        password: password,
      );

      await StorageService.saveToken(response.token);
      await StorageService.saveUserId(response.user.id);

      state = const AsyncData(null);

      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    try {
      final authService = ref.read(authServiceProvider);

      final response = await authService.register(
        name: name,
        email: email,
        password: password,
      );

      await StorageService.saveToken(response.token);
      await StorageService.saveUserId(response.user.id);

      state = const AsyncData(null);

      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  Future<UserModel?> getMe() async {
    try {
      final token = await StorageService.getToken();

      if (token == null) return null;

      final authService = ref.read(authServiceProvider);

      return await authService.getMe(token);
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      final token = await StorageService.getToken();
      if (token != null) {
        final authService = ref.read(authServiceProvider);
        await authService.logout(token);
      }
    } catch (e) {
    } finally {
      await StorageService.clearAll();
      ref.read(currentUserProvider.notifier).clear();
    }
  }

  Future<bool> updateProfile({
    String? name,
    required String phone,
    required String city,
    required String userState,
    required String address,
  }) async {
    try {
      final token = await StorageService.getToken();

      if (token == null) {
        throw Exception('User not authenticated');
      }

      final authService = ref.read(authServiceProvider);

      await authService.updateProfile(
        name: name,
        phone: phone,
        city: city,
        state: userState,
        address: address,
        token: token,
      );

      await ref.read(currentUserProvider.notifier).refresh();

      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> uploadAvatar(String filePath) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final authService = ref.read(authServiceProvider);
      await authService.uploadAvatar(filePath: filePath, token: token);

      await ref.read(currentUserProvider.notifier).refresh();

      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = const AsyncLoading();
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final authService = ref.read(authServiceProvider);
      final newToken = await authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        token: token,
      );

      await StorageService.saveToken(newToken);
      state = const AsyncData(null);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }
}
