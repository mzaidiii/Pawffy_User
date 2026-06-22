class MedicalRecordModel {
  final String id;
  final String petId;
  final String? diagnosis;
  final String? prescription;
  final String? allergies;
  final String? symptoms;
  final String? reportUrl;
  final String? createdByVet;
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicalRecordModel({
    required this.id,
    required this.petId,
    this.diagnosis,
    this.prescription,
    this.allergies,
    this.symptoms,
    this.reportUrl,
    this.createdByVet,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MedicalRecordModel.fromJson(Map<String, dynamic> json) {
    return MedicalRecordModel(
      id: json['id'] ?? '',
      petId: json['petId'] ?? '',
      diagnosis: json['diagnosis'],
      prescription: json['prescription'],
      allergies: json['allergies'],
      symptoms: json['symptoms'],
      reportUrl: json['reportUrl'],
      createdByVet: json['createdByVet'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'petId': petId,
      'diagnosis': diagnosis,
      'prescription': prescription,
      'allergies': allergies,
      'symptoms': symptoms,
      'reportUrl': reportUrl,
    };
  }

  MedicalRecordModel copyWith({
    String? diagnosis,
    String? prescription,
    String? allergies,
    String? symptoms,
    String? reportUrl,
  }) {
    return MedicalRecordModel(
      id: id,
      petId: petId,
      diagnosis: diagnosis ?? this.diagnosis,
      prescription: prescription ?? this.prescription,
      allergies: allergies ?? this.allergies,
      symptoms: symptoms ?? this.symptoms,
      reportUrl: reportUrl ?? this.reportUrl,
      createdByVet: createdByVet,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
