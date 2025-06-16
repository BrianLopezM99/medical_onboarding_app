import 'dart:convert';
import 'package:medical_onboarding_app/features/customer/domain/customer_entity.dart';

class CustomerModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String dateOfBirth;
  final String? medicalRecordNumber;
  final String status;

  CustomerModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    this.medicalRecordNumber,
    required this.status,
  });

  factory CustomerModel.fromEntity(Customer customer) {
    return CustomerModel(
      id: customer.id,
      firstName: customer.firstName,
      lastName: customer.lastName,
      email: customer.email,
      phone: customer.phone,
      dateOfBirth: customer.dateOfBirth.toIso8601String(),
      medicalRecordNumber: customer.medicalRecordNumber,
      status: customer.status.name,
    );
  }

  Customer toEntity() {
    return Customer(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      dateOfBirth: DateTime.parse(dateOfBirth),
      medicalRecordNumber: medicalRecordNumber,
      status: CustomerStatus.values.firstWhere((e) => e.name == status),
    );
  }

  // Save to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'medicalRecordNumber': medicalRecordNumber,
      'status': status,
    };
  }

  // To read JSON
  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'],
      dateOfBirth: json['dateOfBirth'],
      medicalRecordNumber: json['medicalRecordNumber'],
      status: json['status'],
    );
  }

  // Save sharedpreferences as String
  static String encodeList(List<CustomerModel> models) =>
      jsonEncode(models.map((m) => m.toJson()).toList());

  static List<CustomerModel> decodeList(String jsonStr) {
    return (jsonDecode(jsonStr) as List)
        .map((e) => CustomerModel.fromJson(e))
        .toList();
  }
}
