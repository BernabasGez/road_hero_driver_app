/// Normalized wrapper for all API responses.
class ApiResponse<T> {
  final String status;
  final String message;
  final T? data;

  const ApiResponse({
    required this.status,
    required this.message,
    this.data,
  });

  bool get isSuccess => status == 'success';

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromData,
  ) {
    return ApiResponse(
      status: json['status'] ?? 'error',
      message: json['message'] ?? '',
      data: json['data'] != null && fromData != null
          ? fromData(json['data'])
          : json['data'] as T?,
    );
  }
}
