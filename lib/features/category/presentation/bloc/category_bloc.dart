import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/category/domain/usecases/get_categories_usecase.dart';
import 'package:tressy/features/category/presentation/bloc/category_event.dart';
import 'package:tressy/features/category/presentation/bloc/category_state.dart';
import 'package:tressy/shared/domain/usecases/get_salons_usecase.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetSalonsUseCase getSalonsUseCase; // Shared use case

  CategoryBloc({
    required this.getCategoriesUseCase,
    required this.getSalonsUseCase,
  }) : super(const CategoryState()) {
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<RefreshCategoriesEvent>(_onRefreshCategories);
    on<LoadCategorySalonsEvent>(_onLoadCategorySalons);
  }

  Future<void> _onLoadCategories(
    LoadCategoriesEvent event,
    Emitter<CategoryState> emit,
  ) async {
    // Don't reload if we already have categories (cache mechanism)
    if (state.categories.isNotEmpty) {
      return;
    }

    emit(state.copyWith(status: CategoryStatus.loading, clearError: true));

    final result = await getCategoriesUseCase();

    result.fold(
      (failure) => emit(state.copyWith(
        status: CategoryStatus.failure,
        errorMessage: _mapFailureToMessage(failure),
      )),
      (categories) => emit(state.copyWith(
        status: CategoryStatus.success,
        categories: categories,
        clearError: true,
      )),
    );
  }

  Future<void> _onRefreshCategories(
    RefreshCategoriesEvent event,
    Emitter<CategoryState> emit,
  ) async {
    // Force reload regardless of cache
    emit(state.copyWith(status: CategoryStatus.loading, clearError: true));

    final result = await getCategoriesUseCase();

    result.fold(
      (failure) => emit(state.copyWith(
        status: CategoryStatus.failure,
        errorMessage: _mapFailureToMessage(failure),
      )),
      (categories) => emit(state.copyWith(
        status: CategoryStatus.success,
        categories: categories,
        clearError: true,
      )),
    );
  }

  Future<void> _onLoadCategorySalons(
    LoadCategorySalonsEvent event,
    Emitter<CategoryState> emit,
  ) async {
    // Don't load more if already loading or no more data
    if (event.isLoadMore) {
      if (state.isLoadingMoreSalons || !state.hasMoreSalons) {
        return;
      }
      emit(state.copyWith(isLoadingMoreSalons: true));
    } else {
      emit(state.copyWith(
        isSalonsLoading: true,
        clearSalonsError: true,
      ));
    }

    final result = await getSalonsUseCase(
      GetSalonsParams(
        latitude: event.latitude,
        longitude: event.longitude,
        category: event.categoryId,
        limit: event.limit ?? 10,
        page: event.page ?? (event.isLoadMore ? state.currentPage + 1 : 1),
        gender: event.gender,
        search: event.search,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isSalonsLoading: false,
        isLoadingMoreSalons: false,
        salonsError: _mapFailureToMessage(failure),
      )),
      (salons) {
        // For load more, append to existing list; otherwise replace
        final updatedSalons = event.isLoadMore 
            ? [...state.salons, ...salons]
            : salons;
        
        final currentPage = event.page ?? (event.isLoadMore ? state.currentPage + 1 : 1);
        final hasMore = salons.length >= (event.limit ?? 10);
        
        emit(state.copyWith(
          isSalonsLoading: false,
          isLoadingMoreSalons: false,
          salons: updatedSalons,
          clearSalonsError: true,
          currentPage: currentPage,
          hasMoreSalons: hasMore,
        ));
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return failure.message;
    } else {
      return 'An unexpected error occurred';
    }
  }
}
