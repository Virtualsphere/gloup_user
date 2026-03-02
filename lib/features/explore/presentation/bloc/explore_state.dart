import 'package:equatable/equatable.dart';
import 'package:tressy/shared/domain/entities/salon_entity.dart';

class ExploreState extends Equatable {
  final bool isLoading;
  final List<SalonEntity> salons;
  final String? error;
  final int currentPage;
  final int totalPages;
  final bool hasMore;
  final bool isLoadingMore;

  const ExploreState({
    this.isLoading = false,
    this.salons = const [],
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  ExploreState copyWith({
    bool? isLoading,
    List<SalonEntity>? salons,
    String? error,
    bool clearError = false,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ExploreState(
      isLoading: isLoading ?? this.isLoading,
      salons: salons ?? this.salons,
      error: clearError ? null : (error ?? this.error),
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        salons,
        error,
        currentPage,
        totalPages,
        hasMore,
        isLoadingMore,
      ];
}
