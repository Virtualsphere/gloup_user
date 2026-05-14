import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// Load nearby salons without search query (initial load)
class LoadNearbySalonsEvent extends SearchEvent {
  final double latitude;
  final double longitude;
  final int? limit;
  final String? gender;

  const LoadNearbySalonsEvent({
    required this.latitude,
    required this.longitude,
    this.limit,
    this.gender,
  });

  @override
  List<Object?> get props => [latitude, longitude, limit, gender];
}

/// Search salons with query and filters
class SearchSalonsEvent extends SearchEvent {
  final double latitude;
  final double longitude;
  final String query;
  final String? categoryId;
  final String? gender;
  final int? limit;

  const SearchSalonsEvent({
    required this.latitude,
    required this.longitude,
    required this.query,
    this.categoryId,
    this.gender,
    this.limit,
  });

  @override
  List<Object?> get props =>
      [latitude, longitude, query, categoryId, gender, limit];
}

/// Apply filters without search query
class ApplyFiltersEvent extends SearchEvent {
  final double latitude;
  final double longitude;
  final String? categoryId;
  final String? gender;
  final int? limit;

  const ApplyFiltersEvent({
    required this.latitude,
    required this.longitude,
    this.categoryId,
    this.gender,
    this.limit,
  });

  @override
  List<Object?> get props => [latitude, longitude, categoryId, gender, limit];
}

/// Load more results (pagination)
class LoadMoreSalonsEvent extends SearchEvent {
  final int nextPage;

  const LoadMoreSalonsEvent({required this.nextPage});

  @override
  List<Object?> get props => [nextPage];
}

/// Clear search and return to nearby salons
class ClearSearchEvent extends SearchEvent {
  const ClearSearchEvent();
}
