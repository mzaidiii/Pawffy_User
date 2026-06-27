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

      final existingPet = state.value?.firstWhere((p) => p.id == petId, orElse: () => updated);
      final merged = existingPet != null
          ? updated.copyWith(
              imageUrl: (updated.imageUrl == null || updated.imageUrl!.isEmpty) ? existingPet.imageUrl : updated.imageUrl,
              bookingCount: updated.bookingCount == 0 ? existingPet.bookingCount : updated.bookingCount,
              medicalRecordCount: updated.medicalRecordCount == 0 ? existingPet.medicalRecordCount : updated.medicalRecordCount,
            )
          : updated;

      // Replace locally
      state = AsyncData(
        state.value!.map((p) => p.id == petId ? merged : p).toList(),
      );
      refreshBackground();
      return merged;
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

      final existingPet = state.value?.firstWhere((p) => p.id == petId, orElse: () => updated);
      final merged = existingPet != null
          ? updated.copyWith(
              name: updated.name.isEmpty ? existingPet.name : updated.name,
              species: updated.species.isEmpty ? existingPet.species : updated.species,
              breed: updated.breed.isEmpty ? existingPet.breed : updated.breed,
              gender: updated.gender.isEmpty ? existingPet.gender : updated.gender,
              age: updated.age == 0 ? existingPet.age : updated.age,
              weight: (updated.weight == '0' || updated.weight.isEmpty) ? existingPet.weight : updated.weight,
              color: updated.color.isEmpty ? existingPet.color : updated.color,
              medicalNotes: (updated.medicalNotes == null || updated.medicalNotes!.isEmpty) ? existingPet.medicalNotes : updated.medicalNotes,
              vaccinationStatus: updated.vaccinationStatus.isEmpty ? existingPet.vaccinationStatus : updated.vaccinationStatus,
              bookingCount: updated.bookingCount == 0 ? existingPet.bookingCount : updated.bookingCount,
              medicalRecordCount: updated.medicalRecordCount == 0 ? existingPet.medicalRecordCount : updated.medicalRecordCount,
            )
          : updated;

      // Replace locally
      state = AsyncData(
        state.value!.map((p) => p.id == petId ? merged : p).toList(),
      );
      refreshBackground();
      return merged;
    } catch (e) {
      return null;
    }
  }

  Future<void> refreshBackground() async {
    try {
      final service = ref.read(petServiceProvider);
      final pets = await service.getMyPets();
      state = AsyncData(pets);
    } catch (_) {
      // Ignore background errors
    }
  }
}
