import 'package:pawffy/features/booking/data/models/booking_model.dart';

class VendorModel {
  final String id;
  final String? userId;
  final String name;
  final String email;
  final String serviceType;
  final String specialization;
  final int experienceYears;
  final String clinicName;
  final String? clinicAddress;
  final String? clinicCity;
  final String? profileImage;
  final String? phone;
  final String consultationFee;
  final double? rating;
  final String city;
  final String state;
  final bool availableStatus;
  final int bookingCount;
  final int reviewCount;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<VendorServiceModel> services;
  final List<dynamic>? availability;
  final Map<String, dynamic>? timings;

  VendorModel({
    required this.id,
    this.userId,
    required this.name,
    required this.email,
    required this.serviceType,
    required this.specialization,
    required this.experienceYears,
    required this.clinicName,
    this.clinicAddress,
    this.clinicCity,
    this.profileImage,
    this.phone,
    required this.consultationFee,
    this.rating,
    required this.city,
    required this.state,
    required this.availableStatus,
    this.bookingCount = 0,
    this.reviewCount = 0,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
    this.services = const [],
    this.availability,
    this.timings,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    final count = json['_count'] as Map<String, dynamic>? ?? {};

    // Vendor API may return 'location' as a single string like "Ghaziabad, UP"
    // Parse it into city/state if separate fields aren't present.
    String city = json['city'] ?? '';
    String state = json['state'] ?? '';
    if (city.isEmpty && json['location'] != null) {
      final parts = json['location'].toString().split(',');
      city = parts.isNotEmpty ? parts[0].trim() : '';
      state = parts.length > 1 ? parts[1].trim() : '';
    }

    return VendorModel(
      id: json['id'] ?? json['businessId'] ?? '',
      userId:
          json['userId'] ?? (json['user'] is Map ? json['user']['id'] : null),
      name: json['name'] ?? json['contactName'] ?? '',
      email: json['email'] ?? '',
      serviceType: () {
        final String type = json['serviceType']?.toString() ?? '';
        if (type.isNotEmpty) return type;
        final servicesList = json['services'];
        if (servicesList is List && servicesList.isNotEmpty) {
          final first = servicesList.first;
          if (first is Map) {
            final st = first['serviceType']?.toString() ?? '';
            if (st.isNotEmpty) return st;
          }
        }
        return 'vet';
      }(),
      specialization: json['specialization'] ?? json['description'] ?? '',
      experienceYears: json['experienceYears'] ?? 0,
      clinicName: json['clinicName'] ?? json['businessName'] ?? '',
      clinicAddress: json['clinicAddress'] ?? json['location'],
      clinicCity: json['clinicCity'],
      profileImage: json['profileImage'] ?? json['logo'],
      phone: json['phone'],
      consultationFee: () {
        String fee = json['consultationFee']?.toString() ?? '';
        if (fee.isEmpty || fee == '0' || fee == '0.0') {
          final servicesList = json['services'];
          if (servicesList is List && servicesList.isNotEmpty) {
            double minPrice = double.maxFinite;
            for (final s in servicesList) {
              if (s is Map) {
                final rawPrice = s['price'] ?? s['minPrice'];
                if (rawPrice != null) {
                  final p = double.tryParse(rawPrice.toString()) ?? double.maxFinite;
                  if (p < minPrice) minPrice = p;
                }
              }
            }
            if (minPrice != double.maxFinite) {
              return minPrice.toStringAsFixed(0);
            }
          }
        }
        return fee.isEmpty ? '0' : fee;
      }(),
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,
      city: city,
      state: state,
      availableStatus: json['availableStatus'] ?? json['isOnline'] ?? false,
      bookingCount: count['bookings'] ?? json['bookingCount'] ?? 0,
      reviewCount: count['reviews'] ?? json['reviewCount'] ?? 0,
      isVerified: json['isVerified'] ?? json['verified'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      services: () {
        final servicesList = json['services'];
        if (servicesList is List) {
          return servicesList.map((s) => VendorServiceModel.fromJson(s)).toList();
        }
        return <VendorServiceModel>[];
      }(),
      availability: json['availability'] is List ? json['availability'] : null,
      timings: json['timings'] is Map ? Map<String, dynamic>.from(json['timings']) : null,
    );
  }
}

