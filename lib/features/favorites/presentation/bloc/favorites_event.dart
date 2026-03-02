import 'package:equatable/equatable.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

class ToggleFavoriteEvent extends FavoritesEvent {
  final int storeId;
  final bool currentIsFavorite; // Current favorite status from server data

  const ToggleFavoriteEvent(this.storeId, this.currentIsFavorite);

  @override
  List<Object?> get props => [storeId, currentIsFavorite];
}

class LoadFavoritesEvent extends FavoritesEvent {
  const LoadFavoritesEvent();
}
