import 'package:equatable/equatable.dart';
import 'package:tressy/features/booking_confirmation/domain/entities/guest_entity.dart';

class GuestState extends Equatable {
  final bool isLoading;
  final List<GuestEntity> guests;
  final int? selectedGuestIndex;
  final String? errorMessage;
  final bool isAdding;
  final String? addSuccessMessage;
  final bool isUpdating;
  final String? updateSuccessMessage;

  const GuestState({
    this.isLoading = false,
    this.guests = const [],
    this.selectedGuestIndex,
    this.errorMessage,
    this.isAdding = false,
    this.addSuccessMessage,
    this.isUpdating = false,
    this.updateSuccessMessage,
  });

  /// Initial state
  factory GuestState.initial() {
    return const GuestState();
  }

  /// Loading state
  GuestState copyWithLoading() {
    return GuestState(
      isLoading: true,
      guests: guests,
      selectedGuestIndex: selectedGuestIndex,
      isAdding: isAdding,
    );
  }

  /// Adding state
  GuestState copyWithAdding() {
    return GuestState(
      isLoading: isLoading,
      guests: guests,
      selectedGuestIndex: selectedGuestIndex,
      isAdding: true,
    );
  }

  /// Add success state
  GuestState copyWithAddSuccess(String message) {
    return GuestState(
      isLoading: isLoading,
      guests: guests,
      selectedGuestIndex: selectedGuestIndex,
      isAdding: false,
      addSuccessMessage: message,
      isUpdating: isUpdating,
    );
  }

  /// Updating state
  GuestState copyWithUpdating() {
    return GuestState(
      isLoading: isLoading,
      guests: guests,
      selectedGuestIndex: selectedGuestIndex,
      isAdding: isAdding,
      isUpdating: true,
    );
  }

  /// Update success state
  GuestState copyWithUpdateSuccess(String message) {
    return GuestState(
      isLoading: isLoading,
      guests: guests,
      selectedGuestIndex: selectedGuestIndex,
      isAdding: isAdding,
      isUpdating: false,
      updateSuccessMessage: message,
    );
  }

  /// Success state
  GuestState copyWithSuccess(List<GuestEntity> guests) {
    return GuestState(
      isLoading: false,
      guests: guests,
      selectedGuestIndex: selectedGuestIndex,
    );
  }

  /// Error state
  GuestState copyWithError(String message) {
    return GuestState(
      isLoading: false,
      guests: guests,
      selectedGuestIndex: selectedGuestIndex,
      errorMessage: message,
    );
  }

  /// Update selected guest
  GuestState copyWithSelectedGuest(int? index) {
    return GuestState(
      isLoading: isLoading,
      guests: guests,
      selectedGuestIndex: index,
      errorMessage: errorMessage,
    );
  }

  /// Get selected guest
  GuestEntity? get selectedGuest {
    if (selectedGuestIndex != null &&
        selectedGuestIndex! >= 0 &&
        selectedGuestIndex! < guests.length) {
      return guests[selectedGuestIndex!];
    }
    return null;
  }

  /// Check if a guest is selected
  bool get hasSelectedGuest => selectedGuestIndex != null;

  @override
  List<Object?> get props => [
        isLoading,
        guests,
        selectedGuestIndex,
        errorMessage,
        isAdding,
        addSuccessMessage,
        isUpdating,
        updateSuccessMessage,
      ];
}
