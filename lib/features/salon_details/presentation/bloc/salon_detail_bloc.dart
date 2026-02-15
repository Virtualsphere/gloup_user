import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tressy/features/salon_details/domain/usecases/get_salon_details_usecase.dart';
import 'package:tressy/features/salon_details/presentation/bloc/salon_detail_event.dart';
import 'package:tressy/features/salon_details/presentation/bloc/salon_detail_state.dart';

class SalonDetailBloc extends Bloc<SalonDetailEvent, SalonDetailState> {
  final GetSalonDetailsUseCase getSalonDetailsUseCase;

  SalonDetailBloc({
    required this.getSalonDetailsUseCase,
  }) : super(SalonDetailState.initial()) {
    on<LoadSalonDetailEvent>(_onLoadSalonDetail);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
  }

  Future<void> _onLoadSalonDetail(
    LoadSalonDetailEvent event,
    Emitter<SalonDetailState> emit,
  ) async {
    emit(state.copyWithLoading());

    final result = await getSalonDetailsUseCase(event.salonId);

    result.fold(
      (failure) => emit(state.copyWithError(failure.message)),
      (salonDetail) => emit(state.copyWithSuccess(salonDetail)),
    );
  }

  void _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<SalonDetailState> emit,
  ) {
    emit(state.copyWithFavoriteToggled());
    // TODO: Call API to update favorite status on server
  }
}
