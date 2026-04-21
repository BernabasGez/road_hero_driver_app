class UserModel {
  final int? id;
  final String fullName;
  final String phoneNumber;
  final String? email;
  final String? role;
  final String? language;
  final String? profileImageUrl;

  const UserModel({
    this.id,
    required this.fullName,
    required this.phoneNumber,
    this.email,
    this.role,
    this.language,
    this.profileImageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['full_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      email: json['email'],
      role: json['role'],
      language: json['language'],
      profileImageUrl: json['profile_image_url'],
    );
  }

  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        'phone_number': phoneNumber,
        if (email != null) 'email': email,
        if (language != null) 'language': language,
      };

  UserModel copyWith({
    int? id,
    String? fullName,
    String? phoneNumber,
    String? email,
    String? role,
    String? language,
    String? profileImageUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      role: role ?? this.role,
      language: language ?? this.language,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
