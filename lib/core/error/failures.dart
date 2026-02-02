import 'package:equatable/equatable.dart';

/// Base failure class
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Server failure
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

/// Network failure
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error occurred']);
}

/// Cache failure
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

/// Validation failure
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation error occurred']);
}

/// Authentication failure
class AuthenticationFailure extends Failure {
  const AuthenticationFailure([super.message = 'Authentication failed']);
}

/// Authorization failure
class AuthorizationFailure extends Failure {
  const AuthorizationFailure([super.message = 'Authorization failed']);
}

/// Not found failure
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found']);
}
