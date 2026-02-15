import 'package:equatable/equatable.dart';

abstract class SalonDetailEvent extends Equatable {
  const SalonDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load salon details
class LoadSalonDetailEvent extends SalonDetailEvent {
  final String salonId;

  const LoadSalonDetailEvent(this.salonId);

  @override
  List<Object?> get props => [salonId];
}

/// Event to toggle favorite status
class ToggleFavoriteEvent extends SalonDetailEvent {
  const ToggleFavoriteEvent();
}
