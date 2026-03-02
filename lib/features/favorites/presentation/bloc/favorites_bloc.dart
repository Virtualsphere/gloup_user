import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/favorites/domain/usecases/get_favorites_usecase.dart';
import 'package:tressy/features/favorites/domain/usecases/toggle_favorite_usecase.dart';
import 'package:tressy/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:tressy/features/favorites/presentation/bloc/favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final ToggleFavoriteUseCase toggleFavoriteUseCase;
  final GetFavoritesUseCase getFavoritesUseCase;

  FavoritesBloc({
    required this.toggleFavoriteUseCase,
    required this.getFavoritesUseCase,
  }) : super(const FavoritesState()) {
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<LoadFavoritesEvent>(_onLoadFavorites);
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    // Check if we have an optimistic update for this store
    final hasOptimistic = state.optimisticUpdates.containsKey(event.storeId);
    final currentValue = hasOptimistic 
        ? state.optimisticUpdates[event.storeId]! 
        : event.currentIsFavorite;
    
    // Calculate the new value (toggle from current effective value)
    final newValue = !currentValue;
    
    // Update the optimistic map
    final updatedMap = Map<int, bool>.from(state.optimisticUpdates);
    updatedMap[event.storeId] = newValue;
    
    emit(state.copyWith(
      status: FavoritesStatus.loading,
      lastToggledStoreId: event.storeId,
      lastToggledValue: newValue,
      optimisticUpdates: updatedMap,
      clearError: true,
    ));

    // Call API
    final result = await toggleFavoriteUseCase(event.storeId);

    result.fold(
      (failure) {
        // On failure, revert the optimistic update
        final revertedMap = Map<int, bool>.from(state.optimisticUpdates);
        revertedMap.remove(event.storeId);
        
        
        emit(state.copyWith(
          status: FavoritesStatus.failure,
          errorMessage: _mapFailureToMessage(failure),
          optimisticUpdates: revertedMap,
          incrementToastCounter: true, // Increment to trigger toast
        ));
      },
      (favoriteEntity) {
        // On success, keep the optimistic update
        // It will be used until widget receives fresh server data
        
        emit(state.copyWith(
          status: FavoritesStatus.success,
          message: favoriteEntity.message,
          incrementToastCounter: true, // Increment to trigger toast
          // Keep optimisticUpdates - don't clear it
        ));
      },
    );
  }

  Future<void> _onLoadFavorites(
    LoadFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(state.copyWith(listStatus: FavoritesListStatus.loading));

    final result = await getFavoritesUseCase();

    result.fold(
      (failure) {
        emit(state.copyWith(
          listStatus: FavoritesListStatus.failure,
          listErrorMessage: _mapFailureToMessage(failure),
        ));
      },
      (favorites) {
        emit(state.copyWith(
          listStatus: FavoritesListStatus.loaded,
          favoritesList: favorites,
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
