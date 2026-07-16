import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pawffy/features/auth/providers/current_user_provider.dart';
import 'package:pawffy/features/auth/providers/auth_controller.dart';
import 'address_service.dart';

class AddressModel {
  final String id;
  final String label;
  final String fullName;
  final String mobile;
  final String addressLine1;
  final String addressLine2;
  final String landmark;
  final String city;
  final String state;
  final String pinCode;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.label,
    required this.fullName,
    required this.mobile,
    required this.addressLine1,
    this.addressLine2 = '',
    this.landmark = '',
    required this.city,
    required this.state,
    required this.pinCode,
    this.isDefault = false,
  });

  AddressModel copyWith({
    String? id,
    String? label,
    String? fullName,
    String? mobile,
    String? addressLine1,
    String? addressLine2,
    String? landmark,
    String? city,
    String? state,
    String? pinCode,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      fullName: fullName ?? this.fullName,
      mobile: mobile ?? this.mobile,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      landmark: landmark ?? this.landmark,
      city: city ?? this.city,
      state: state ?? this.state,
      pinCode: pinCode ?? this.pinCode,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

final addressServiceProvider = Provider<AddressService>((ref) => AddressService());

class AddressNotifier extends AsyncNotifier<List<AddressModel>> {
  @override
  Future<List<AddressModel>> build() async {
    final service = ref.watch(addressServiceProvider);
    return await service.getAddresses();
  }

  Future<void> addAddress(AddressModel address) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(addressServiceProvider);
      final newAddress = await service.createAddress(
        label: address.label,
        address: address.addressLine1,
        city: address.city,
        state: address.state,
        pincode: address.pinCode,
        isDefault: address.isDefault,
      );

      final currentList = state.value ?? [];
      if (newAddress.isDefault) {
        final updatedList = currentList.map((a) => a.copyWith(isDefault: false)).toList();
        _syncToProfile(newAddress);
        return [...updatedList, newAddress];
      }
      return [...currentList, newAddress];
    });
  }

  Future<void> updateAddress(AddressModel updated) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(addressServiceProvider);
      final newAddress = await service.updateAddress(
        id: updated.id,
        label: updated.label,
        address: updated.addressLine1,
        city: updated.city,
        state: updated.state,
      );

      final currentList = state.value ?? [];
      final wasDefault = currentList.firstWhere((a) => a.id == updated.id, orElse: () => updated).isDefault;
      
      final updatedList = currentList.map((a) => a.id == updated.id ? newAddress.copyWith(isDefault: wasDefault) : a).toList();
      
      if (wasDefault) {
        _syncToProfile(newAddress);
      }
      return updatedList;
    });
  }

  Future<void> deleteAddress(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(addressServiceProvider);
      await service.deleteAddress(id);
      final currentList = state.value ?? [];
      final toDelete = currentList.firstWhere((a) => a.id == id, orElse: () => AddressModel(id: '', label: '', fullName: '', mobile: '', addressLine1: '', city: '', state: '', pinCode: ''));
      
      if (toDelete.isDefault) {
        ref.read(authControllerProvider.notifier).updateProfile(
          name: '',
          phone: '',
          city: '',
          userState: '',
          address: '',
        );
      }
      return currentList.where((a) => a.id != id).toList();
    });
  }

  Future<void> setDefault(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(addressServiceProvider);
      await service.setDefaultAddress(id);
      
      final currentList = state.value ?? [];
      final updatedList = currentList.map((a) => a.copyWith(isDefault: a.id == id)).toList();
      final defaultAddress = updatedList.firstWhere((a) => a.isDefault, orElse: () => AddressModel(id: '', label: '', fullName: '', mobile: '', addressLine1: '', city: '', state: '', pinCode: ''));
      if (defaultAddress.id.isNotEmpty) {
        _syncToProfile(defaultAddress);
      }
      return updatedList;
    });
  }

  void _syncToProfile(AddressModel address) {
    final user = ref.read(currentUserProvider).asData?.value;
    if (user != null) {
      ref.read(authControllerProvider.notifier).updateProfile(
        name: address.fullName.isNotEmpty ? address.fullName : user.name,
        phone: address.mobile.isNotEmpty ? address.mobile : (user.phone ?? ''),
        city: address.city,
        userState: address.state,
        address: address.addressLine1,
      );
    }
  }
}

final addressProvider = AsyncNotifierProvider<AddressNotifier, List<AddressModel>>(
  AddressNotifier.new,
);
