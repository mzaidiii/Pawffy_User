class VetServiceModel {
  final String id;
  final String name;
  final double price;
  final int duration;
  final String description;

  VetServiceModel({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.description,
  });

  factory VetServiceModel.fromJson(Map<String, dynamic> json) {
    return VetServiceModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      duration: json['duration'] ?? 0,
      description: json['description'] ?? '',
    );
  }
}

class BookingPetModel {
  final String id;
  final String name;
  final String species;
  final String? breed;
  final int? age;

  BookingPetModel({
    required this.id,
    required this.name,
    required this.species,
    this.breed,
    this.age,
  });

  factory BookingPetModel.fromJson(Map<String, dynamic> json) {
    return BookingPetModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      species: json['species'] ?? '',
      breed: json['breed'],
      age: json['age'],
    );
  }
}

class BookingVetModel {
  final String id;
  final String name;
  final String clinicName;
  final String? clinicAddress;
  final String? phone;

  BookingVetModel({
    required this.id,
    required this.name,
    required this.clinicName,
    this.clinicAddress,
    this.phone,
  });

  factory BookingVetModel.fromJson(Map<String, dynamic> json) {
    return BookingVetModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      clinicName: json['clinicName'] ?? '',
      clinicAddress: json['clinicAddress'] ?? json['clinicAddressFormatted'],
      phone: json['phone'],
    );
  }
}

class BookingServiceModel {
  final String id;
  final String name;
  final double price;
  final int? duration;

  BookingServiceModel({
    required this.id,
    required this.name,
    required this.price,
    this.duration,
  });

  factory BookingServiceModel.fromJson(Map<String, dynamic> json) {
    return BookingServiceModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      duration: json['duration'],
    );
  }
}

class BookingPaymentModel {
  final String paymentStatus;
  final double amount;
  final int pawPoints;
  final String? paymentMethod;

  BookingPaymentModel({
    required this.paymentStatus,
    required this.amount,
    required this.pawPoints,
    this.paymentMethod,
  });

  factory BookingPaymentModel.fromJson(Map<String, dynamic> json) {
    return BookingPaymentModel(
      paymentStatus: json['paymentStatus'] ?? json['status'] ?? 'pending',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      pawPoints: json['pawPoints'] ?? 0,
      paymentMethod: json['paymentMethod'],
    );
  }
}

class BookingModel {
  final String id;
  final String? appointmentId;
  final String status;
  final String bookingType;
  final DateTime bookingDate;
  final String bookingTime;
  final String? dateTimeFormatted;
  final BookingPetModel pet;
  final BookingVetModel vet;
  final BookingServiceModel service;
  final BookingPaymentModel? payment;

  BookingModel({
    required this.id,
    this.appointmentId,
    required this.status,
    required this.bookingType,
    required this.bookingDate,
    required this.bookingTime,
    this.dateTimeFormatted,
    required this.pet,
    required this.vet,
    required this.service,
    this.payment,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? '',
      appointmentId: json['appointmentId'],
      status: json['status'] ?? 'pending',
      bookingType: json['bookingType'] ?? 'vet',
      bookingDate: json['bookingDate'] != null
          ? DateTime.parse(json['bookingDate'])
          : DateTime.now(),
      bookingTime: json['bookingTime'] ?? '',
      dateTimeFormatted: json['dateTimeFormatted'],
      pet: BookingPetModel.fromJson(json['pet'] ?? {}),
      vet: BookingVetModel.fromJson(json['vet'] ?? {}),
      service: BookingServiceModel.fromJson(json['service'] ?? {}),
      payment: json['payment'] != null
          ? BookingPaymentModel.fromJson(json['payment'])
          : null,
    );
  }
}

class CouponModel {
  final String code;
  final double discount;

  CouponModel({required this.code, required this.discount});

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      code: json['code'] ?? '',
      discount: double.tryParse(json['discount']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class PaymentSummaryModel {
  final String serviceName;
  final double servicePrice;
  final double platformFee;
  final double tax;
  final String? taxRate;
  final double discount;
  final CouponModel? coupon;
  final double total;
  final int pawPoints;

  PaymentSummaryModel({
    required this.serviceName,
    required this.servicePrice,
    required this.platformFee,
    required this.tax,
    this.taxRate,
    required this.discount,
    this.coupon,
    required this.total,
    required this.pawPoints,
  });

  factory PaymentSummaryModel.fromJson(Map<String, dynamic> json) {
    return PaymentSummaryModel(
      serviceName: json['serviceName'] ?? '',
      servicePrice:
          double.tryParse(json['servicePrice']?.toString() ?? '0') ?? 0.0,
      platformFee:
          double.tryParse(json['platformFee']?.toString() ?? '0') ?? 0.0,
      tax: double.tryParse(json['tax']?.toString() ?? '0') ?? 0.0,
      taxRate: json['taxRate']?.toString(),
      discount: double.tryParse(json['discount']?.toString() ?? '0') ?? 0.0,
      coupon: json['coupon'] != null
          ? CouponModel.fromJson(json['coupon'])
          : null,
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0.0,
      pawPoints: json['pawPoints'] ?? 0,
    );
  }
}

class PaymentIntentModel {
  final String clientSecret;
  final String paymentIntentId;
  final double amount;
  final String currency;
  final PaymentSummaryModel? summary;

  PaymentIntentModel({
    required this.clientSecret,
    required this.paymentIntentId,
    required this.amount,
    required this.currency,
    this.summary,
  });

  factory PaymentIntentModel.fromJson(Map<String, dynamic> json) {
    return PaymentIntentModel(
      clientSecret: json['clientSecret'] ?? '',
      paymentIntentId: json['paymentIntentId'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      currency: json['currency'] ?? 'usd',
      summary: json['summary'] != null
          ? PaymentSummaryModel.fromJson(json['summary'])
          : null,
    );
  }
}
