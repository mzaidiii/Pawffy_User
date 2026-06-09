import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

// ── Position Provider (fetched ONCE, shared everywhere) ──
final positionProvider = FutureProvider<Position?>((ref) async {
  try {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
  } catch (e) {
    return null;
  }
});

// ── Placemark Provider (depends on position) ─────────────
final placemarkProvider = FutureProvider<Placemark?>((ref) async {
  final position = await ref.watch(positionProvider.future);
  if (position == null) return null;

  try {
    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    return placemarks.isNotEmpty ? placemarks.first : null;
  } catch (e) {
    return null;
  }
});

// ── Country Provider ──────────────────────────────────────
final countryProvider = FutureProvider<String>((ref) async {
  final placemark = await ref.watch(placemarkProvider.future);
  final country = placemark?.country ?? 'United States';

  // normalize
  if (country.toLowerCase().contains('india')) return 'India';
  if (country.toLowerCase().contains('united states')) return 'United States';
  return 'United States'; // default fallback
});

// ── Location Text Provider (for home screen display) ──────
final locationTextProvider = FutureProvider<String>((ref) async {
  final placemark = await ref.watch(placemarkProvider.future);
  if (placemark == null) return 'Location unavailable';

  final subLocality = placemark.subLocality ?? '';
  final locality = placemark.locality ?? '';
  final state = placemark.administrativeArea ?? '';

  if (subLocality.isNotEmpty) return '$subLocality, $state';
  if (locality.isNotEmpty) return '$locality, $state';
  return state;
});
