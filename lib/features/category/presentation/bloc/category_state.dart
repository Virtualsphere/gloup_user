import 'package:equatable/equatable.dart';
import 'package:tressy/features/category/domain/entities/category_entity.dart';
import 'package:tressy/shared/domain/entities/salon_entity.dart';

enum CategoryStatus { initial, loading, success, failure }

class CategoryState extends Equatable {
  final CategoryStatus status;
  final List<CategoryEntity> categories;
  final String? errorMessage;

  // Category Salons with pagination
  final bool isSalonsLoading;
  final List<SalonEntity> salons; // Using shared SalonEntity
  final String? salonsError;
  final int currentPage;
  final int totalPages;
  final bool hasMoreSalons;
  final bool isLoadingMoreSalons;

  const CategoryState({
    this.status = CategoryStatus.initial,
    this.categories = const [],
    this.errorMessage,
    this.isSalonsLoading = false,
    this.salons = const [],
    this.salonsError,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasMoreSalons = true,
    this.isLoadingMoreSalons = false,
  });

  CategoryState copyWith({
    CategoryStatus? status,
    List<CategoryEntity>? categories,
    String? errorMessage,
    bool clearError = false,
    bool? isSalonsLoading,
    List<SalonEntity>? salons,
    String? salonsError,
    bool clearSalonsError = false,
    int? currentPage,
    int? totalPages,
    bool? hasMoreSalons,
    bool? isLoadingMoreSalons,
  }) {
    return CategoryState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSalonsLoading: isSalonsLoading ?? this.isSalonsLoading,
      salons: salons ?? this.salons,
      salonsError: clearSalonsError ? null : (salonsError ?? this.salonsError),
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMoreSalons: hasMoreSalons ?? this.hasMoreSalons,
      isLoadingMoreSalons: isLoadingMoreSalons ?? this.isLoadingMoreSalons,
    );
  }

  @override
  List<Object?> get props => [
        status,
        categories,
        errorMessage,
        isSalonsLoading,
        salons,
        salonsError,
        currentPage,
        totalPages,
        hasMoreSalons,
        isLoadingMoreSalons,
      ];
}
