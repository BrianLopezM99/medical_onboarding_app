class Customer {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final DateTime dateOfBirth;
  final String? medicalRecordNumber;
  final CustomerStatus status;

  Customer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    this.medicalRecordNumber,
    required this.status,
  });
}

enum CustomerStatus { newCustomer, onboarding, active, inactive }
