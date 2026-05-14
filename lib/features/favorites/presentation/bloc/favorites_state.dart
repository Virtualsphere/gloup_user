import 'package:equatable/equatable.dart';
import 'package:tressy/shared/domain/entities/salon_entity.dart';

enum FavoritesStatus { initial, loading, success, failure }

enum FavoritesListStatus { initial, loading, loaded, failure }

class FavoritesState extends Equatable {
  final FavoritesStatus status;
  final String? message;
  final String? errorMessage;
  final int? lastToggledStoreId;
  final bool? lastToggledValue; // The new favorite status after toggle
  final Map<int, bool> optimisticUpdates; // Store optimistic updates
  final int _toastCounter; // Counter to ensure toast is shown only once

  // Favorites list
  final FavoritesListStatus listStatus;
  final List<SalonEntity> favoritesList;
  final String? listErrorMessage;

  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.message,
    this.errorMessage,
    this.lastToggledStoreId,
    this.lastToggledValue,
    this.optimisticUpdates = const {},
    int toastCounter = 0,
    this.listStatus = FavoritesListStatus.initial,
    this.favoritesList = const [],
    this.listErrorMessage,
  }) : _toastCounter = toastCounter;

  FavoritesState copyWith({
    FavoritesStatus? status,
    String? message,
    String? errorMessage,
    int? lastToggledStoreId,
    bool? lastToggledValue,
    Map<int, bool>? optimisticUpdates,
    bool clearError = false,
    bool incrementToastCounter = false,
    FavoritesListStatus? listStatus,
    List<SalonEntity>? favoritesList,
    String? listErrorMessage,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      message: message ?? this.message,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastToggledStoreId: lastToggledStoreId ?? this.lastToggledStoreId,
      lastToggledValue: lastToggledValue ?? this.lastToggledValue,
      optimisticUpdates: optimisticUpdates ?? this.optimisticUpdates,
      toastCounter: incrementToastCounter ? _toastCounter + 1 : _toastCounter,
      listStatus: listStatus ?? this.listStatus,
      favoritesList: favoritesList ?? this.favoritesList,
      listErrorMessage: listErrorMessage ?? this.listErrorMessage,
    );
  }

  int get toastCounter => _toastCounter;

  // Get favorite status for a store
  bool isFavorite(int storeId, bool serverValue) {
    // If we have an optimistic update for this store, check if it matches server value
    if (optimisticUpdates.containsKey(storeId)) {
      final optimisticValue = optimisticUpdates[storeId]!;

      // If optimistic value matches server value, the server has been updated
      // We can trust the server value now
      if (optimisticValue == serverValue) {
        print('🔍 Optimistic matches server for $storeId - using server value');
        return serverValue;
      }

      // Otherwise, still waiting for server to update, use optimistic
      print(
          '🔍 Using optimistic for $storeId: $optimisticValue (server: $serverValue)');
      return optimisticValue;
    }

    // No optimistic update, use server value
    return serverValue;
  }

  @override
  List<Object?> get props => [
        status,
        message,
        errorMessage,
        lastToggledStoreId,
        lastToggledValue,
        optimisticUpdates,
        _toastCounter,
        listStatus,
        favoritesList,
        listErrorMessage,
      ];
}
