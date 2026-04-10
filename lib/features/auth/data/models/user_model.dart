class UserModel {
  final String fullName;
  final String phoneNumber;
  final String role;

  UserModel({
    required this.fullName,
    required this.phoneNumber,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      fullName: json['full_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      role: json['role'] ?? '',
    );
  }
}
