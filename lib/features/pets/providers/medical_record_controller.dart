import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/medical_record_model.dart';
import 'pet_provider.dart';

final medicalRecordControllerProvider = AsyncNotifierProvider.family<
    MedicalRecordController, List<MedicalRecordModel>, String>(
  (String arg) => MedicalRecordController(arg),
);

class MedicalRecordController extends AsyncNotifier<List<MedicalRecordModel>> {
  final String petId;
  MedicalRecordController(this.petId);

  @override
  Future<List<MedicalRecordModel>> build() async {
    return await _fetch(petId);
  }

  Future<List<MedicalRecordModel>> _fetch(String petId) async {
    final service = ref.read(medicalRecordServiceProvider);
    return await service.getMedicalRecordsForPet(petId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      state = AsyncData(await _fetch(petId));
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<MedicalRecordModel?> createRecord(Map<String, dynamic> body) async {
    try {
      final service = ref.read(medicalRecordServiceProvider);
      final Map<String, dynamic> requestBody = {
        ...body,
        'petId': petId,
      };
      final newRecord = await service.createMedicalRecord(requestBody);

      state = AsyncData([...state.value ?? [], newRecord]);
      return newRecord;
    } catch (e) {
      return null;
    }
  }

  Future<MedicalRecordModel?> updateRecord(
    String recordId,
    Map<String, dynamic> body,
  ) async {
    try {
      final service = ref.read(medicalRecordServiceProvider);
      final Map<String, dynamic> requestBody = {
        ...body,
        'petId': petId,
      };
      final updated = await service.updateMedicalRecord(recordId, requestBody);

      state = AsyncData(
        state.value!.map((r) => r.id == recordId ? updated : r).toList(),
      );
      return updated;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteRecord(String recordId) async {
    try {
      final service = ref.read(medicalRecordServiceProvider);
      await service.deleteMedicalRecord(recordId);

      state = AsyncData(state.value!.where((r) => r.id != recordId).toList());
      return true;
    } catch (e) {
      return false;
    }
  }
}
