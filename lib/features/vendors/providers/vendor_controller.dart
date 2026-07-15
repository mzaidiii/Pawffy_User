import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/vendor_model.dart';
import 'vendor_provider.dart';

// ── Home screen — fetches all vendors ────────────────────────────────────────
final vendorControllerProvider =
    AsyncNotifierProvider<VendorController, List<VendorModel>>(() => VendorController());

class VendorController extends AsyncNotifier<List<VendorModel>> {
  @override
  Future<List<VendorModel>> build() async {
    return await ref.read(vendorServiceProvider).getAllVendors();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      state = AsyncData(await ref.read(vendorServiceProvider).getAllVendors());
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

// ── VendorListScreen — filtered by serviceType ───────────────────────────────
final vendorListControllerProvider =
    AsyncNotifierProvider<VendorListController, List<VendorModel>>(
      () => VendorListController(),
    );

class VendorListController extends AsyncNotifier<List<VendorModel>> {
  String _serviceType = 'vet';
  String? _search;
  String? _city;
  bool? _isOnline;

  @override
  Future<List<VendorModel>> build() async {
    return [];
  }

  Future<void> setParams({
    required String serviceType,
    String? search,
    String? city,
    bool? isOnline,
  }) async {
    _serviceType = serviceType;
    _search = search;
    _city = city;
    _isOnline = isOnline;
    await _fetch();
  }

  Future<void> refresh() async {
    await _fetch();
  }

  Future<void> _fetch() async {
    state = const AsyncLoading();
    try {
      final vendors = await ref
          .read(vendorServiceProvider)
          .getVendorsByServiceType(
            serviceType: _serviceType,
            search: _search,
            city: _city,
            isOnline: _isOnline,
          );
      state = AsyncData(vendors);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

// ── VendorDetailScreen — single vendor by id ───────────────────────────────────
final vendorDetailControllerProvider =
    AsyncNotifierProvider<VendorDetailController, VendorModel?>(
      () => VendorDetailController(),
    );

class VendorDetailController extends AsyncNotifier<VendorModel?> {
  String _vendorId = '';

  @override
  Future<VendorModel?> build() async {
    return null;
  }

  Future<void> loadVendor(String vendorId) async {
    _vendorId = vendorId;
    await _fetch();
  }

  Future<void> refresh() async {
    await _fetch();
  }

  Future<void> _fetch() async {
    if (_vendorId.isEmpty) return;
    state = const AsyncLoading();
    try {
      final vendor = await ref.read(vendorServiceProvider).getVendorById(_vendorId);
      state = AsyncData(vendor);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}
