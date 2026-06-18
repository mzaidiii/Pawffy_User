import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/vet_model.dart';
import 'vet_provider.dart';

// ── Home screen — fetches all vets ────────────────────────────────────────
final vetControllerProvider =
    AsyncNotifierProvider<VetController, List<VetModel>>(() => VetController());

class VetController extends AsyncNotifier<List<VetModel>> {
  @override
  Future<List<VetModel>> build() async {
    return await ref.read(vetServiceProvider).getAllVets();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      state = AsyncData(await ref.read(vetServiceProvider).getAllVets());
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

// ── VetListScreen — filtered by serviceType ───────────────────────────────
final vetListControllerProvider =
    AsyncNotifierProvider<VetListController, List<VetModel>>(
      () => VetListController(),
    );

class VetListController extends AsyncNotifier<List<VetModel>> {
  String _serviceType = 'vet';
  String? _search;
  String? _city;

  @override
  Future<List<VetModel>> build() async {
    return [];
  }

  Future<void> setParams({
    required String serviceType,
    String? search,
    String? city,
  }) async {
    _serviceType = serviceType;
    _search = search;
    _city = city;
    await _fetch();
  }

  Future<void> refresh() async {
    await _fetch();
  }

  Future<void> _fetch() async {
    state = const AsyncLoading();
    try {
      final vets = await ref
          .read(vetServiceProvider)
          .getVetsByServiceType(
            serviceType: _serviceType,
            search: _search,
            city: _city,
          );
      state = AsyncData(vets);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

// ── VetDetailScreen — single vet by id ───────────────────────────────────
final vetDetailControllerProvider =
    AsyncNotifierProvider<VetDetailController, VetModel?>(
      () => VetDetailController(),
    );

class VetDetailController extends AsyncNotifier<VetModel?> {
  String _vetId = '';

  @override
  Future<VetModel?> build() async {
    return null;
  }

  Future<void> loadVet(String vetId) async {
    _vetId = vetId;
    await _fetch();
  }

  Future<void> refresh() async {
    await _fetch();
  }

  Future<void> _fetch() async {
    if (_vetId.isEmpty) return;
    state = const AsyncLoading();
    try {
      final vet = await ref.read(vetServiceProvider).getVetById(_vetId);
      state = AsyncData(vet);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}
