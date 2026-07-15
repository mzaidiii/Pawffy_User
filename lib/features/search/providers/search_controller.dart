import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pawffy/features/vendors/data/models/vendor_model.dart';
import 'package:pawffy/features/vendors/providers/vendor_provider.dart';

final searchControllerProvider =
    AsyncNotifierProvider<SearchController, List<VendorModel>>(
      () => SearchController(),
    );

class SearchController extends AsyncNotifier<List<VendorModel>> {
  Timer? _debounceTimer;
  String _currentQuery = '';
  String _currentFilter = 'All';
  @override
  Future<List<VendorModel>> build() async {
    // Start with all providers pre-loaded on search screen opening
    return _fetchList();
  }

  void updateSearch(String query, String filter) {
    _currentQuery = query;
    _currentFilter = filter;
    _debounceTimer?.cancel();

    // Debounce for 400ms to avoid spamming the backend API
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _fetchResults();
    });
  }

  Future<void> _fetchResults() async {
    state = const AsyncLoading();
    try {
      final results = await _fetchList();
      state = AsyncData(results);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<List<VendorModel>> _fetchList() async {
    final serviceType = _mapFilterToServiceType(_currentFilter);
    return await ref
        .read(vendorServiceProvider)
        .getVendorsByServiceType(serviceType: serviceType, search: _currentQuery);
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    try {
      final results = await _fetchList();
      state = AsyncData(results);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  String? _mapFilterToServiceType(String filter) {
    switch (filter) {
      case 'Pet Sitting':
        return 'sitter';
      case 'Dog Walking':
        return 'walker';
      case 'Grooming':
        return 'groomer';
      case 'Training':
        return 'trainer';
      case 'Vet':
        return 'vet';
      case 'Boarding':
        return 'boarding';
      case 'Transport':
        return 'transport';
      default:
        return null; // 'All' returns null, which queries all categories
    }
  }
}
