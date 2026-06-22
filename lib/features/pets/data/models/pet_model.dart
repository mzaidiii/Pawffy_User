class PetModel {
  final String id;
  final String ownerId;
  final String name;
  final String species;
  final String breed;
  final String gender;
  final int age;
  final String weight;
  final String color;
  final String? medicalNotes;
  final String vaccinationStatus;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int bookingCount;
  final int medicalRecordCount;

  PetModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.species,
    required this.breed,
    required this.gender,
    required this.age,
    required this.weight,
    required this.color,
    this.medicalNotes,
    required this.vaccinationStatus,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.bookingCount = 0,
    this.medicalRecordCount = 0,
  });

  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      id: json['id'] ?? '',
      ownerId: json['ownerId'] ?? '',
      name: json['name'] ?? '',
      species: json['species'] ?? '',
      breed: json['breed'] ?? '',
      gender: json['gender'] ?? '',
      age: json['age'] ?? 0,
      weight: json['weight']?.toString() ?? '0',
      color: json['color'] ?? '',
      medicalNotes: json['medicalNotes'],
      vaccinationStatus: json['vaccinationStatus'] ?? '',
      imageUrl: json['imageUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      bookingCount: json['_count']?['bookings'] ?? 0,
      medicalRecordCount: json['_count']?['medicalRecords'] ?? 0,
    );
  }

  PetModel copyWith({
    String? name,
    String? species,
    String? breed,
    String? gender,
    int? age,
    String? weight,
    String? color,
    String? medicalNotes,
    String? vaccinationStatus,
    String? imageUrl,
    int? bookingCount,
    int? medicalRecordCount,
  }) {
    return PetModel(
      id: id,
      ownerId: ownerId,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      color: color ?? this.color,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      vaccinationStatus: vaccinationStatus ?? this.vaccinationStatus,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      bookingCount: bookingCount ?? this.bookingCount,
      medicalRecordCount: medicalRecordCount ?? this.medicalRecordCount,
    );
  }
}
