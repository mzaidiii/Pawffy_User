import 'package:pawffy/core/networks/api_constants.dart';
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
    final userMap = json['user'] is Map ? Map<String, dynamic>.from(json['user']) : null;
    final stats = json['stats'] is Map ? Map<String, dynamic>.from(json['stats']) : <String, dynamic>{};
    final count = json['_count'] is Map
        ? Map<String, dynamic>.from(json['_count'])
        : (userMap != null && userMap['_count'] is Map
            ? Map<String, dynamic>.from(userMap['_count'])
            : <String, dynamic>{});

    // Vendor API may return 'location' as a single string like "Ghaziabad, UP"
    // Parse it into city/state if separate fields aren't present.
    String city = json['city'] ?? '';
    String state = json['state'] ?? '';
    if (city.isEmpty && json['location'] != null) {
      final parts = json['location'].toString().split(',');
      city = parts.isNotEmpty ? parts[0].trim() : '';
      state = parts.length > 1 ? parts[1].trim() : '';
    }

    // Comprehensive parsing for profile image
    dynamic rawImage = json['profileImage'] ??
        json['profilePicture'] ??
        json['avatar'] ??
        json['logo'] ??
        json['logoUrl'] ??
        json['businessLogo'] ??
        json['clinicLogo'] ??
        json['clinicImage'] ??
        json['coverImage'] ??
        json['bannerImage'] ??
        json['image'] ??
        json['imageUrl'] ??
        json['photo'] ??
        json['photoUrl'] ??
        json['profile_image'] ??
        json['vendorImage'];

    if ((rawImage == null || rawImage.toString().trim().isEmpty) &&
        json['images'] is List &&
        (json['images'] as List).isNotEmpty) {
      final firstImg = (json['images'] as List).first;
      if (firstImg is String) {
        rawImage = firstImg;
      } else if (firstImg is Map) {
        rawImage = firstImg['url'] ?? firstImg['path'] ?? firstImg['src'] ?? firstImg['imageUrl'];
      }
    }

    if ((rawImage == null || rawImage.toString().trim().isEmpty) && userMap != null) {
      rawImage = userMap['profileImage'] ??
          userMap['profilePicture'] ??
          userMap['avatar'] ??
          userMap['image'] ??
          userMap['photo'] ??
          userMap['photoUrl'];
    }

    String? parsedImage;
    if (rawImage != null && rawImage.toString().trim().isNotEmpty) {
      String imgStr = rawImage.toString().trim();

      // Check for base64 data URI or raw base64 string
      if (imgStr.startsWith('data:image') || imgStr.startsWith('data:') || imgStr.contains(';base64,')) {
        parsedImage = imgStr;
      } else if (!imgStr.startsWith('http') && !imgStr.startsWith('/') && !imgStr.contains('\\') && imgStr.length > 50) {
        parsedImage = imgStr;
      } else {
        // Replace localhost / 127.0.0.1 / 10.0.2.2 with ApiConstants.baseUrl for real devices
        if (imgStr.contains('localhost') || imgStr.contains('127.0.0.1') || imgStr.contains('10.0.2.2')) {
          try {
            final uri = Uri.parse(imgStr);
            imgStr = '${ApiConstants.baseUrl}${uri.path}';
          } catch (_) {
            imgStr = imgStr
                .replaceAll(RegExp(r'http://localhost:\d+'), ApiConstants.baseUrl)
                .replaceAll(RegExp(r'http://127\.0\.0\.1:\d+'), ApiConstants.baseUrl)
                .replaceAll(RegExp(r'http://10\.0\.2\.2:\d+'), ApiConstants.baseUrl);
          }
        }

        if (imgStr.startsWith('http://') || imgStr.startsWith('https://')) {
          parsedImage = imgStr;
        } else if (imgStr.startsWith('/')) {
          parsedImage = '${ApiConstants.baseUrl}$imgStr';
        } else {
          parsedImage = '${ApiConstants.baseUrl}/$imgStr';
        }
      }
    }

    // Comprehensive parsing for booking count
    int parsedBookingCount = 0;
    final countValue = count['bookings'] ??
        count['Booking'] ??
        count['booking'] ??
        count['vendorBookings'] ??
        count['requests'] ??
        stats['completedBookings'] ??
        stats['totalBookings'] ??
        stats['bookings'] ??
        stats['bookingCount'] ??
        stats['bookingsCount'];

    if (countValue != null) {
      parsedBookingCount = int.tryParse(countValue.toString()) ?? 0;
    }
    if (parsedBookingCount == 0) {
      final directCount = json['bookingCount'] ??
          json['totalBookings'] ??
          json['completedBookings'] ??
          json['bookingsCount'] ??
          json['bookings_count'] ??
          json['completed_bookings'];
      if (directCount != null) {
        parsedBookingCount = int.tryParse(directCount.toString()) ?? 0;
      }
    }
    if (parsedBookingCount == 0 && json['bookings'] is List) {
      parsedBookingCount = (json['bookings'] as List).length;
    }
    if (parsedBookingCount == 0 && json['requests'] is List) {
      parsedBookingCount = (json['requests'] as List).length;
    }

    // Comprehensive parsing for review count
    int parsedReviewCount = 0;
    final rCountValue = count['reviews'] ??
        count['Review'] ??
        count['review'] ??
        count['vendorReviews'] ??
        stats['reviews'] ??
        stats['reviewCount'];
    if (rCountValue != null) {
      parsedReviewCount = int.tryParse(rCountValue.toString()) ?? 0;
    }
    if (parsedReviewCount == 0) {
      final directRCount = json['reviewCount'] ?? json['totalReviews'] ?? json['reviewsCount'];
      if (directRCount != null) {
        parsedReviewCount = int.tryParse(directRCount.toString()) ?? 0;
      }
    }

    return VendorModel(
      id: json['id'] ?? json['businessId'] ?? '',
      userId: json['userId'] ?? (userMap != null ? userMap['id'] : null),
      name: json['name'] ?? json['contactName'] ?? (userMap != null ? userMap['name'] : '') ?? '',
      email: json['email'] ?? (userMap != null ? userMap['email'] : '') ?? '',
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
      profileImage: parsedImage,
      phone: json['phone'] ?? (userMap != null ? userMap['phone'] : null),
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
      bookingCount: parsedBookingCount,
      reviewCount: parsedReviewCount,
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

