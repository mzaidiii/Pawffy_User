import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/pet_service.dart';
import '../data/services/medical_record_service.dart';
import '../data/services/vaccination_service.dart';

final petServiceProvider = Provider<PetService>((ref) => PetService());
final medicalRecordServiceProvider = Provider<MedicalRecordService>((ref) => MedicalRecordService());
final vaccinationServiceProvider = Provider<VaccinationService>((ref) => VaccinationService());

