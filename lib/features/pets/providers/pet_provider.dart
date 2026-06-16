import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/pet_service.dart';

final petServiceProvider = Provider<PetService>((ref) => PetService());
