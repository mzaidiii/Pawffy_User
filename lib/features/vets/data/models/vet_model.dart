class VetModel {
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
  final DateTime createdAt;
  final DateTime updatedAt;

  VetModel({
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
    required this.createdAt,
    required this.updatedAt,
  });

  factory VetModel.fromJson(Map<String, dynamic> json) {
    final count = json['_count'] as Map<String, dynamic>? ?? {};
    return VetModel(
      id: json['id'] ?? '',
      userId:
          json['userId'] ?? (json['user'] is Map ? json['user']['id'] : null),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      serviceType: json['serviceType'] ?? 'vet',
      specialization: json['specialization'] ?? '',
      experienceYears: json['experienceYears'] ?? 0,
      clinicName: json['clinicName'] ?? '',
      clinicAddress: json['clinicAddress'],
      clinicCity: json['clinicCity'],
      profileImage: json['profileImage'],
      phone: json['phone'],
      consultationFee: json['consultationFee']?.toString() ?? '0',
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      availableStatus: json['availableStatus'] ?? false,
      bookingCount: count['bookings'] ?? 0,
      reviewCount: count['reviews'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }
}
