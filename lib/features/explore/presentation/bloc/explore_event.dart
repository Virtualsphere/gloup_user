import 'package:equatable/equatable.dart';

abstract class ExploreEvent extends Equatable {
  const ExploreEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load salons
class LoadExploreSalonsEvent extends ExploreEvent {
  final double latitude;
  final double longitude;
  final int? limit;
  final int? page;
  final String? gender;
  final String? search;
  final bool isLoadMore;

  const LoadExploreSalonsEvent({
    required this.latitude,
    required this.longitude,
    this.limit,
    this.page,
    this.gender,
    this.search,
    this.isLoadMore = false,
  });

  @override
  List<Object?> get props =>
      [latitude, longitude, limit, page, gender, search, isLoadMore];
}

/// Event to refresh salons
class RefreshExploreSalonsEvent extends ExploreEvent {
  final double latitude;
  final double longitude;

  const RefreshExploreSalonsEvent({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}
