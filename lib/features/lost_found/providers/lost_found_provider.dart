import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/lost_found_model.dart';
import '../data/services/lost_found_service.dart';

final lostFoundServiceProvider = Provider<LostFoundService>((ref) {
  return LostFoundService();
});

final lostFoundFeedProvider =
    AsyncNotifierProvider<LostFoundNotifier, List<LostFoundReportModel>>(
  () => LostFoundNotifier(),
);

class LostFoundNotifier extends AsyncNotifier<List<LostFoundReportModel>> {
  @override
  Future<List<LostFoundReportModel>> build() async {
    return await ref.read(lostFoundServiceProvider).getAllReports();
  }

  Future<void> refreshFeed() async {
    state = const AsyncLoading();
    try {
      final list = await ref.read(lostFoundServiceProvider).getAllReports();
      state = AsyncData(list);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<LostFoundReportModel> reportLostPet(Map<String, dynamic> data) async {
    final report = await ref.read(lostFoundServiceProvider).createLostReport(data);
    await refreshFeed();
    return report;
  }

  Future<LostFoundReportModel> reportFoundPet(Map<String, dynamic> data) async {
    final report = await ref.read(lostFoundServiceProvider).createFoundReport(data);
    await refreshFeed();
    return report;
  }

  Future<void> deleteReport(String id, String type) async {
    if (type.toLowerCase() == 'lost') {
      await ref.read(lostFoundServiceProvider).deleteLostReport(id);
    } else {
      await ref.read(lostFoundServiceProvider).deleteFoundReport(id);
    }
    await refreshFeed();
  }
}

// Detail fetchers
final lostReportDetailsProvider =
    FutureProvider.family<LostFoundReportModel, String>((ref, id) {
  return ref.watch(lostFoundServiceProvider).getLostReportById(id);
});

final foundReportDetailsProvider =
    FutureProvider.family<LostFoundReportModel, String>((ref, id) {
  return ref.watch(lostFoundServiceProvider).getFoundReportById(id);
});
