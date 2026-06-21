import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pawffy/features/auth/providers/current_user_provider.dart';
import 'package:pawffy/features/auth/providers/auth_controller.dart';

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

class AddressNotifier extends Notifier<List<AddressModel>> {
  @override
  List<AddressModel> build() {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.asData?.value;
    final List<AddressModel> list = [];

    if (user != null && user.address != null && user.address!.isNotEmpty) {
      list.add(
        AddressModel(
          id: 'primary',
          label: 'Primary / Home',
          fullName: user.name,
          mobile: user.phone ?? '',
          addressLine1: user.address!,
          city: user.city ?? '',
          state: user.state ?? '',
          pinCode: '110001',
          isDefault: true,
        ),
      );
    }
    return list;
  }

  void addAddress(AddressModel address) {
    if (address.isDefault) {
      state = state.map((a) => a.copyWith(isDefault: false)).toList();
      _syncToProfile(address);
    }
    state = [...state, address];
  }

  void updateAddress(AddressModel updated) {
    if (updated.isDefault) {
      state = state.map((a) => a.copyWith(isDefault: false)).toList();
    }
    state = state.map((a) => a.id == updated.id ? updated : a).toList();

    if (updated.id == 'primary' || updated.isDefault) {
      _syncToProfile(updated);
    }
  }

  void deleteAddress(String id) {
    final toDelete = state.firstWhere((a) => a.id == id, orElse: () => AddressModel(id: '', label: '', fullName: '', mobile: '', addressLine1: '', city: '', state: '', pinCode: ''));
    state = state.where((a) => a.id != id).toList();
    
    if (id == 'primary' || toDelete.isDefault) {
      ref.read(authControllerProvider.notifier).updateProfile(
        name: '',
        phone: '',
        city: '',
        userState: '',
        address: '',
      );
    }
  }

  void setDefault(String id) {
    state = state.map((a) => a.copyWith(isDefault: a.id == id)).toList();
    final defaultAddress = state.firstWhere((a) => a.isDefault, orElse: () => AddressModel(id: '', label: '', fullName: '', mobile: '', addressLine1: '', city: '', state: '', pinCode: ''));
    if (defaultAddress.id.isNotEmpty) {
      _syncToProfile(defaultAddress);
    }
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

final addressProvider = NotifierProvider<AddressNotifier, List<AddressModel>>(
  AddressNotifier.new,
);
