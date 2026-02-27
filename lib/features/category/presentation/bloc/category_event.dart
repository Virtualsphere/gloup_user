import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategoriesEvent extends CategoryEvent {
  const LoadCategoriesEvent();
}

class RefreshCategoriesEvent extends CategoryEvent {
  const RefreshCategoriesEvent();
}

class LoadCategorySalonsEvent extends CategoryEvent {
  final double latitude;
  final double longitude;
  final String categoryId;
  final int? limit;
  final int? page;
  final String? gender;
  final String? search;
  final bool isLoadMore;

  const LoadCategorySalonsEvent({
    required this.latitude,
    required this.longitude,
    required this.categoryId,
    this.limit,
    this.page,
    this.gender,
    this.search,
    this.isLoadMore = false,
  });

  @override
  List<Object?> get props => [latitude, longitude, categoryId, limit, page, gender, search, isLoadMore];
}
