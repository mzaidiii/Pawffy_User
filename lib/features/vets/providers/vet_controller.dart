import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/vet_model.dart';
import 'vet_provider.dart';

final vetControllerProvider =
    AsyncNotifierProvider<VetController, List<VetModel>>(VetController.new);

class VetController extends AsyncNotifier<List<VetModel>> {
  @override
  Future<List<VetModel>> build() async {
    return await _fetchVets();
  }

  Future<List<VetModel>> _fetchVets() async {
    final vetService = ref.read(vetServiceProvider);
    return await vetService.getAllVets();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      state = AsyncData(await _fetchVets());
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}
