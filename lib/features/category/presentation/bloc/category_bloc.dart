import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/category/domain/usecases/get_categories_usecase.dart';
import 'package:tressy/features/category/presentation/bloc/category_event.dart';
import 'package:tressy/features/category/presentation/bloc/category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategoriesUseCase getCategoriesUseCase;

  CategoryBloc({
    required this.getCategoriesUseCase,
  }) : super(const CategoryState()) {
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<RefreshCategoriesEvent>(_onRefreshCategories);
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
