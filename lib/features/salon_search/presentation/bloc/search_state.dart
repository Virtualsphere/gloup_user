import 'package:equatable/equatable.dart';
import 'package:tressy/shared/domain/entities/salon_entity.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchLoaded extends SearchState {
  final List<SalonEntity> salons;
  final bool isSearchActive;
  final String? searchQuery;
  final String? categoryId;
  final String? gender;
  final int currentPage;
  final bool hasMore;

  const SearchLoaded({
    required this.salons,
    this.isSearchActive = false,
    this.searchQuery,
    this.categoryId,
    this.gender,
    this.currentPage = 1,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [
        salons,
        isSearchActive,
        searchQuery,
        categoryId,
        gender,
        currentPage,
        hasMore,
      ];

  SearchLoaded copyWith({
    List<SalonEntity>? salons,
    bool? isSearchActive,
    String? searchQuery,
    String? categoryId,
    String? gender,
    int? currentPage,
    bool? hasMore,
  }) {
    return SearchLoaded(
      salons: salons ?? this.salons,
      isSearchActive: isSearchActive ?? this.isSearchActive,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryId: categoryId ?? this.categoryId,
      gender: gender ?? this.gender,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class SearchLoadingMore extends SearchState {
  final List<SalonEntity> currentSalons;

  const SearchLoadingMore({required this.currentSalons});

  @override
  List<Object?> get props => [currentSalons];
}

class SearchFailure extends SearchState {
  final String message;

  const SearchFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class SearchEmpty extends SearchState {
  final String message;

  const SearchEmpty(this.message);

  @override
  List<Object?> get props => [message];
}
