import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/pet_model.dart';
import 'pet_provider.dart';

final petControllerProvider =
    AsyncNotifierProvider<PetController, List<PetModel>>(() => PetController());

class PetController extends AsyncNotifier<List<PetModel>> {
  @override
  Future<List<PetModel>> build() async {
    return await _fetch();
  }

  Future<List<PetModel>> _fetch() async {
    final service = ref.read(petServiceProvider);
    return await service.getMyPets();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      state = AsyncData(await _fetch());
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<PetModel?> createPet(Map<String, dynamic> body) async {
    try {
      final service = ref.read(petServiceProvider);
      final newPet = await service.createPet(body);

      // Add locally — no refetch needed
      state = AsyncData([...state.value ?? [], newPet]);
      return newPet;
    } catch (e) {
      return null;
    }
  }

  Future<PetModel?> updatePet(String petId, Map<String, dynamic> body) async {
    try {
      final service = ref.read(petServiceProvider);
      final updated = await service.updatePet(petId, body);

      // Replace locally
      state = AsyncData(
        state.value!.map((p) => p.id == petId ? updated : p).toList(),
      );
      return updated;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deletePet(String petId) async {
    try {
      final service = ref.read(petServiceProvider);
      await service.deletePet(petId);

      // Remove locally
      state = AsyncData(state.value!.where((p) => p.id != petId).toList());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<PetModel?> uploadPetImage(String petId, String filePath) async {
    try {
      final service = ref.read(petServiceProvider);
      final updated = await service.uploadPetImage(petId, filePath);

      // Replace locally
      state = AsyncData(
        state.value!.map((p) => p.id == petId ? updated : p).toList(),
      );
      return updated;
    } catch (e) {
      return null;
    }
  }
}
