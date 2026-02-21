import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load carousel banners
class LoadCarouselBannersEvent extends HomeEvent {
  const LoadCarouselBannersEvent();
}

/// Event to load popular services
class LoadPopularServicesEvent extends HomeEvent {
  final double latitude;
  final double longitude;
  final String gender;

  const LoadPopularServicesEvent({
    required this.latitude,
    required this.longitude,
    this.gender = 'unisex',
  });

  @override
  List<Object?> get props => [latitude, longitude, gender];
}

/// Event to load top salons
class LoadTopSalonsEvent extends HomeEvent {
  final double latitude;
  final double longitude;

  const LoadTopSalonsEvent({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}

/// Event to load recommended salons
class LoadRecommendedSalonsEvent extends HomeEvent {
  const LoadRecommendedSalonsEvent();
}

/// Event to load all home data at once
class LoadAllHomeDataEvent extends HomeEvent {
  final double latitude;
  final double longitude;

  const LoadAllHomeDataEvent({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}

/// Event to reset home state
class ResetHomeEvent extends HomeEvent {
  const ResetHomeEvent();
}
