class AuthTokens {
  final String access;
  final String refresh;

  const AuthTokens({required this.access, required this.refresh});

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      // The backend uses 'token' for the access JWT
      access: json['token'] ?? json['access'] ?? '',
      refresh: json['refresh'] ?? '',
    );
  }
}
