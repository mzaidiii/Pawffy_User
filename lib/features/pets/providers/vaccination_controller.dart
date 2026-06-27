import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/vaccination_model.dart';
import 'pet_provider.dart';

final vaccinationControllerProvider = AsyncNotifierProvider.family<
    VaccinationController, List<VaccinationModel>, String>(
  (String arg) => VaccinationController(arg),
);

class VaccinationController extends AsyncNotifier<List<VaccinationModel>> {
  final String petId;
  VaccinationController(this.petId);

  @override
  Future<List<VaccinationModel>> build() async {
    return await _fetch(petId);
  }

  Future<List<VaccinationModel>> _fetch(String petId) async {
    final service = ref.read(vaccinationServiceProvider);
    return await service.getVaccinationsForPet(petId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      state = AsyncData(await _fetch(petId));
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<VaccinationModel?> addVaccination(Map<String, dynamic> body) async {
    try {
      final service = ref.read(vaccinationServiceProvider);
      final Map<String, dynamic> requestBody = {
        ...body,
        'petId': petId,
      };
      final newVaccination = await service.addVaccination(requestBody);

      state = AsyncData([...state.value ?? [], newVaccination]);
      return newVaccination;
    } catch (e) {
      return null;
    }
  }

  Future<VaccinationModel?> updateVaccination(
    String id,
    Map<String, dynamic> body,
  ) async {
    try {
      final service = ref.read(vaccinationServiceProvider);
      final Map<String, dynamic> requestBody = {
        ...body,
        'petId': petId,
      };
      final updated = await service.updateVaccination(id, requestBody);

      state = AsyncData(
        state.value!.map((v) => v.id == id ? updated : v).toList(),
      );
      return updated;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteVaccination(String id) async {
    try {
      final service = ref.read(vaccinationServiceProvider);
      await service.deleteVaccination(id);

      state = AsyncData(state.value!.where((v) => v.id != id).toList());
      return true;
    } catch (e) {
      return false;
    }
  }
}
