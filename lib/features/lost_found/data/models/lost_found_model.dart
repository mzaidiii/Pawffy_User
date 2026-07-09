class PetLocationModel {
  final double latitude;
  final double longitude;
  final String address;

  PetLocationModel({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  factory PetLocationModel.fromJson(Map<String, dynamic> json) {
    return PetLocationModel(
      latitude: double.tryParse(json['latitude']?.toString() ?? '') ??
          (json['latitude'] is num ? (json['latitude'] as num).toDouble() : 0.0),
      longitude: double.tryParse(json['longitude']?.toString() ?? '') ??
          (json['longitude'] is num ? (json['longitude'] as num).toDouble() : 0.0),
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }
}

class LostFoundReportModel {
  final String id;
  final String reportType; // "lost" | "found"
  final String? name; // only lost reports
  final int? age; // only lost reports
  final String color;
  final String? height;
  final String? weight;
  final String breed;
  final String gender;
  final String description;
  final List<String> images;
  final PetLocationModel location;
  final DateTime createdAt;
  final String? reporterName;
  final String? reporterEmail;
  final String? reporterPhone;
  final String? reporterId;

  LostFoundReportModel({
    required this.id,
    required this.reportType,
    this.name,
    this.age,
    required this.color,
    this.height,
    this.weight,
    required this.breed,
    required this.gender,
    required this.description,
    required this.images,
    required this.location,
    required this.createdAt,
    this.reporterName,
    this.reporterEmail,
    this.reporterPhone,
    this.reporterId,
  });

  factory LostFoundReportModel.fromJson(Map<String, dynamic> json) {
    // Some endpoints wrap the type, or we infer from the endpoint structure
    String type = json['postType'] ?? json['reportType'] ?? json['type'] ?? '';
    if (type.isEmpty) {
      // infer from name field or other properties
      type = json['name'] != null ? 'lost' : 'found';
    }

    final rawImages = json['images'];
    final List<String> imgs = [];
    if (rawImages is List) {
      imgs.addAll(rawImages.map((e) => e.toString()));
    } else if (rawImages is String && rawImages.isNotEmpty) {
      imgs.add(rawImages);
    }

    // Handle nested or flat location fields
    final locJson = json['location'];
    final PetLocationModel loc;
    if (locJson is Map<String, dynamic>) {
      loc = PetLocationModel.fromJson(locJson);
    } else {
      loc = PetLocationModel(
        latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
        longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
        address: json['address'] ?? json['location']?.toString() ?? 'Unknown Location',
      );
    }

    // Reporter profile details (if populated by backend user relation)
    final userMap = json['user'] is Map ? json['user'] : {};

    return LostFoundReportModel(
      id: json['id'] ?? '',
      reportType: type.toLowerCase(),
      name: json['name'],
      age: json['age'] is int ? json['age'] : int.tryParse(json['age']?.toString() ?? ''),
      color: json['color'] ?? 'Unknown',
      height: json['height']?.toString(),
      weight: json['weight']?.toString(),
      breed: json['breed'] ?? 'Unknown',
      gender: json['gender'] ?? 'Unknown',
      description: json['description'] ?? '',
      images: imgs,
      location: loc,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      reporterName: userMap['name'] ?? json['reporterName'],
      reporterEmail: userMap['email'] ?? json['reporterEmail'],
      reporterPhone: userMap['phone'] ?? json['reporterPhone'],
      reporterId: userMap['id'] ?? json['userId'] ?? json['reporterId'],
    );
  }
}
