import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  List<AddressModel> build() => []; // ← empty, no hardcoded data

  void addAddress(AddressModel address) {
    if (address.isDefault) {
      state = state.map((a) => a.copyWith(isDefault: false)).toList();
    }
    state = [...state, address];
  }

  void updateAddress(AddressModel updated) {
    if (updated.isDefault) {
      state = state.map((a) => a.copyWith(isDefault: false)).toList();
    }
    state = state.map((a) => a.id == updated.id ? updated : a).toList();
  }

  void deleteAddress(String id) {
    state = state.where((a) => a.id != id).toList();
  }

  void setDefault(String id) {
    state = state.map((a) => a.copyWith(isDefault: a.id == id)).toList();
  }
}

final addressProvider = NotifierProvider<AddressNotifier, List<AddressModel>>(
  AddressNotifier.new,
);
