/// Custom API exceptions
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic error;

  ApiException({
    required this.message,
    this.statusCode,
    this.error,
  });

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException({String? message})
      : super(message: message ?? 'Network error occurred');
}

class TimeoutException extends ApiException {
  TimeoutException({String? message})
      : super(message: message ?? 'Request timeout');
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({String? message})
      : super(message: message ?? 'Unauthorized access', statusCode: 401);
}

class NotFoundException extends ApiException {
  NotFoundException({String? message})
      : super(message: message ?? 'Resource not found', statusCode: 404);
}

class ServerException extends ApiException {
  ServerException({String? message})
      : super(message: message ?? 'Server error occurred', statusCode: 500);
}
