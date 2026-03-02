import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/explore/presentation/bloc/explore_event.dart';
import 'package:tressy/features/explore/presentation/bloc/explore_state.dart';
import 'package:tressy/shared/domain/usecases/get_salons_usecase.dart';

class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  final GetSalonsUseCase getSalonsUseCase;

  ExploreBloc({
    required this.getSalonsUseCase,
  }) : super(const ExploreState()) {
    on<LoadExploreSalonsEvent>(_onLoadSalons);
    on<RefreshExploreSalonsEvent>(_onRefreshSalons);
  }

  Future<void> _onLoadSalons(
    LoadExploreSalonsEvent event,
    Emitter<ExploreState> emit,
  ) async {
    // Don't load more if already loading or no more data
    if (event.isLoadMore) {
      if (state.isLoadingMore || !state.hasMore) {
        return;
      }
      emit(state.copyWith(isLoadingMore: true));
    } else {
      emit(state.copyWith(
        isLoading: true,
        clearError: true,
      ));
    }

    final result = await getSalonsUseCase(
      GetSalonsParams(
        latitude: event.latitude,
        longitude: event.longitude,
        limit: event.limit ?? 20,
        page: event.page ?? (event.isLoadMore ? state.currentPage + 1 : 1),
        gender: event.gender,
        search: event.search,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: _mapFailureToMessage(failure),
      )),
      (salons) {
        // For load more, append to existing list; otherwise replace
        final updatedSalons = event.isLoadMore
            ? [...state.salons, ...salons]
            : salons;

        final currentPage = event.page ?? (event.isLoadMore ? state.currentPage + 1 : 1);
        final hasMore = salons.length >= (event.limit ?? 20);

        emit(state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          salons: updatedSalons,
          clearError: true,
          currentPage: currentPage,
          hasMore: hasMore,
        ));
      },
    );
  }

  Future<void> _onRefreshSalons(
    RefreshExploreSalonsEvent event,
    Emitter<ExploreState> emit,
  ) async {
    add(LoadExploreSalonsEvent(
      latitude: event.latitude,
      longitude: event.longitude,
      limit: 20,
      page: 1,
    ));
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
