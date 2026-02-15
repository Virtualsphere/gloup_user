import 'package:equatable/equatable.dart';
import 'package:tressy/features/salon_details/domain/entities/salon_detail_entity.dart';

class SalonDetailState extends Equatable {
  final bool isLoading;
  final SalonDetailEntity? salonDetail;
  final String? errorMessage;
  final bool isFavorite;

  const SalonDetailState({
    this.isLoading = false,
    this.salonDetail,
    this.errorMessage,
    this.isFavorite = false,
  });

  /// Initial state
  factory SalonDetailState.initial() {
    return const SalonDetailState(
      isLoading: false,
      salonDetail: null,
      errorMessage: null,
      isFavorite: false,
    );
  }

  /// Loading state
  SalonDetailState copyWithLoading() {
    return SalonDetailState(
      isLoading: true,
      salonDetail: salonDetail,
      errorMessage: null,
      isFavorite: isFavorite,
    );
  }

  /// Success state
  SalonDetailState copyWithSuccess(SalonDetailEntity salon) {
    return SalonDetailState(
      isLoading: false,
      salonDetail: salon,
      errorMessage: null,
      isFavorite: isFavorite,
    );
  }

  /// Error state
  SalonDetailState copyWithError(String error) {
    return SalonDetailState(
      isLoading: false,
      salonDetail: salonDetail,
      errorMessage: error,
      isFavorite: isFavorite,
    );
  }

  /// Toggle favorite state
  SalonDetailState copyWithFavoriteToggled() {
    return SalonDetailState(
      isLoading: isLoading,
      salonDetail: salonDetail,
      errorMessage: errorMessage,
      isFavorite: !isFavorite,
    );
  }

  @override
  List<Object?> get props => [isLoading, salonDetail, errorMessage, isFavorite];
}
