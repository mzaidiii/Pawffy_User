import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/vet_service.dart';

final vetServiceProvider = Provider<VetService>((ref) => VetService());
