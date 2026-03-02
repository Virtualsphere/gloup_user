import 'package:equatable/equatable.dart';

/// Entity for favorite toggle response
class FavoriteEntity extends Equatable {
  final bool success;
  final String message;

  const FavoriteEntity({
    required this.success,
    required this.message,
  });

  @override
  List<Object?> get props => [success, message];
}
