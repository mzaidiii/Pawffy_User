class VetModel {
  final String id;
  final String name;
  final String email;
  final String specialization;
  final int experienceYears;
  final String clinicName;
  final String consultationFee;
  final double? rating;
  final String city;
  final String state;
  final bool availableStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  VetModel({
    required this.id,
    required this.name,
    required this.email,
    required this.specialization,
    required this.experienceYears,
    required this.clinicName,
    required this.consultationFee,
    this.rating,
    required this.city,
    required this.state,
    required this.availableStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VetModel.fromJson(Map<String, dynamic> json) {
    return VetModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      specialization: json['specialization'] ?? '',
      experienceYears: json['experienceYears'] ?? 0,
      clinicName: json['clinicName'] ?? '',
      consultationFee: json['consultationFee']?.toString() ?? '0',
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      availableStatus: json['availableStatus'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }
}
