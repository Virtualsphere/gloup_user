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
  final int? limit;
  final int? page;
  final String? gender;

  const LoadPopularServicesEvent({
    required this.latitude,
    required this.longitude,
    this.limit,
    this.page,
    this.gender,
  });

  @override
  List<Object?> get props => [latitude, longitude, limit, page, gender];
}

/// Event to load top salons
class LoadTopSalonsEvent extends HomeEvent {
  final double latitude;
  final double longitude;
  final int? limit;
  final int? page;
  final String? gender;

  const LoadTopSalonsEvent({
    required this.latitude,
    required this.longitude,
    this.limit,
    this.page,
    this.gender,
  });

  @override
  List<Object?> get props => [latitude, longitude, limit, page, gender];
}

/// Event to load recommended salons
class LoadRecommendedSalonsEvent extends HomeEvent {
  final double latitude;
  final double longitude;
  final int? limit;
  final int? page;
  final String? gender;
  final bool isLoadMore; // For infinite scroll

  const LoadRecommendedSalonsEvent({
    required this.latitude,
    required this.longitude,
    this.limit,
    this.page,
    this.gender,
    this.isLoadMore = false,
  });

  @override
  List<Object?> get props =>
      [latitude, longitude, limit, page, gender, isLoadMore];
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
