import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pawffy/core/utils/location_provider.dart';
import 'package:pawffy/features/vets/data/models/vet_model.dart';
import 'package:pawffy/features/vets/providers/vet_provider.dart';
import '../data/services/dashboard_service.dart';

final dashboardServiceProvider = Provider<DashboardService>((ref) {
  return DashboardService();
});

final dashboardBannerProvider = FutureProvider<String?>((ref) async {
  return ref.watch(dashboardServiceProvider).getBannerImage();
});

final dashboardPartnersProvider = FutureProvider<List<VetModel>>((ref) async {
  final position = await ref.watch(positionProvider.future);
  if (position == null) {
    // Fallback to normal vendors if location is unavailable
    return ref.watch(vetServiceProvider).getAllVets();
  }
  return ref.watch(dashboardServiceProvider).getNearbyPartners(
    latitude: position.latitude,
    longitude: position.longitude,
  );
});
