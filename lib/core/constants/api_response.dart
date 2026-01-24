class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson(
    dynamic Function(T value) toJsonT,
  ) {
    return {
      'success': success,
      'message': message,
      'data': data != null ? toJsonT(data as T) : null,
    };
  }
}
