class RegisterResponse {
  final String status;
  final String message;

  RegisterResponse({required this.status, required this.message});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
    );
  }
}
