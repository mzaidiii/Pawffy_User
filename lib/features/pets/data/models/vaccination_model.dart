class VaccinationVetModel {
  final String id;
  final String name;
  final String? clinicName;

  VaccinationVetModel({
    required this.id,
    required this.name,
    this.clinicName,
  });

  factory VaccinationVetModel.fromJson(Map<String, dynamic> json) {
    return VaccinationVetModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      clinicName: json['clinicName'],
    );
  }
}

class VaccinationModel {
  final String id;
  final String petId;
  final String vaccineName;
  final DateTime vaccinationDate;
  final DateTime? nextDueDate;
  final String? vetId;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final VaccinationVetModel? vet;

  VaccinationModel({
    required this.id,
    required this.petId,
    required this.vaccineName,
    required this.vaccinationDate,
    this.nextDueDate,
    this.vetId,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.vet,
  });

  factory VaccinationModel.fromJson(Map<String, dynamic> json) {
    return VaccinationModel(
      id: json['id'] ?? '',
      petId: json['petId'] ?? '',
      vaccineName: json['vaccineName'] ?? '',
      vaccinationDate: json['vaccinationDate'] != null
          ? DateTime.parse(json['vaccinationDate'])
          : DateTime.now(),
      nextDueDate: json['nextDueDate'] != null
          ? DateTime.parse(json['nextDueDate'])
          : null,
      vetId: json['vetId'],
      notes: json['notes'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      vet: json['vet'] != null
          ? VaccinationVetModel.fromJson(json['vet'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'petId': petId,
      'vaccineName': vaccineName,
      'vaccinationDate': vaccinationDate.toIso8601String().substring(0, 10), // Send YYYY-MM-DD
      'nextDueDate': nextDueDate?.toIso8601String().substring(0, 10),
      'vetId': vetId,
      'notes': notes,
    };
  }

  VaccinationModel copyWith({
    String? vaccineName,
    DateTime? vaccinationDate,
    DateTime? nextDueDate,
    String? vetId,
    String? notes,
  }) {
    return VaccinationModel(
      id: id,
      petId: petId,
      vaccineName: vaccineName ?? this.vaccineName,
      vaccinationDate: vaccinationDate ?? this.vaccinationDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      vetId: vetId ?? this.vetId,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      vet: vet,
    );
  }
}
