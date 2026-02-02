/// Generic API response wrapper
class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool success;
  final int? statusCode;
  final dynamic error;

  ApiResponse({
    this.data,
    this.message,
    required this.success,
    this.statusCode,
    this.error,
  });

  factory ApiResponse.success({
    T? data,
    String? message,
    int? statusCode,
  }) {
    return ApiResponse(
      data: data,
      message: message,
      success: true,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.failure({
    String? message,
    int? statusCode,
    dynamic error,
  }) {
    return ApiResponse(
      message: message,
      success: false,
      statusCode: statusCode,
      error: error,
    );
  }
}
