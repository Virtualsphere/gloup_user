import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/salon_search/domain/usecases/get_nearby_salons_usecase.dart';
import 'package:tressy/features/salon_search/domain/usecases/search_salons_usecase.dart';
import 'package:tressy/features/salon_search/presentation/bloc/search_event.dart';
import 'package:tressy/features/salon_search/presentation/bloc/search_state.dart';

/// SearchBloc - ONLY for bottom sheet salon list (nearby/search)
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final GetNearbySalonsUseCase getNearbySalonsUseCase;
  final SearchSalonsUseCase searchSalonsUseCase;

  // Store last request params for pagination
  double? _lastLatitude;
  double? _lastLongitude;
  String? _lastQuery;
  String? _lastCategoryId;
  String? _lastGender;
  int? _lastLimit;

  SearchBloc({
    required this.getNearbySalonsUseCase,
    required this.searchSalonsUseCase,
  }) : super(const SearchInitial()) {
    on<LoadNearbySalonsEvent>(_onLoadNearbySalons);
    on<SearchSalonsEvent>(_onSearchSalons);
    on<ApplyFiltersEvent>(_onApplyFilters);
    on<LoadMoreSalonsEvent>(_onLoadMore);
    on<ClearSearchEvent>(_onClearSearch);
  }

  Future<void> _onLoadNearbySalons(
    LoadNearbySalonsEvent event,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchLoading());

    // Store params for pagination
    _lastLatitude = event.latitude;
    _lastLongitude = event.longitude;
    _lastQuery = null;
    _lastCategoryId = null;
    _lastGender = event.gender;
    _lastLimit = event.limit ?? 20;

    final result = await getNearbySalonsUseCase(
      GetNearbySalonsParams(
        latitude: event.latitude,
        longitude: event.longitude,
        limit: event.limit ?? 20,
        page: 1,
        gender: event.gender,
      ),
    );

    result.fold(
      (failure) => emit(SearchFailure(_mapFailureToMessage(failure))),
      (salons) {
        if (salons.isEmpty) {
          emit(const SearchEmpty('No nearby salons found'));
        } else {
          emit(SearchLoaded(
            salons: salons,
            isSearchActive: false,
            gender: event.gender,
            currentPage: 1,
            hasMore: salons.length >= (event.limit ?? 20),
          ));
        }
      },
    );
  }

  Future<void> _onSearchSalons(
    SearchSalonsEvent event,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchLoading());

    // Store params for pagination
    _lastLatitude = event.latitude;
    _lastLongitude = event.longitude;
    _lastQuery = event.query;
    _lastCategoryId = event.categoryId;
    _lastGender = event.gender;
    _lastLimit = event.limit ?? 20;

    final result = await searchSalonsUseCase(
      SearchSalonsParams(
        latitude: event.latitude,
        longitude: event.longitude,
        query: event.query,
        categoryId: event.categoryId,
        gender: event.gender,
        limit: event.limit ?? 20,
        page: 1,
      ),
    );

    result.fold(
      (failure) => emit(SearchFailure(_mapFailureToMessage(failure))),
      (salons) {
        if (salons.isEmpty) {
          emit(SearchEmpty('No salons found for "${event.query}"'));
        } else {
          emit(SearchLoaded(
            salons: salons,
            isSearchActive: true,
            searchQuery: event.query,
            categoryId: event.categoryId,
            gender: event.gender,
            currentPage: 1,
            hasMore: salons.length >= (event.limit ?? 20),
          ));
        }
      },
    );
  }

  Future<void> _onApplyFilters(
    ApplyFiltersEvent event,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchLoading());

    // Store params for pagination
    _lastLatitude = event.latitude;
    _lastLongitude = event.longitude;
    _lastQuery = null;
    _lastCategoryId = event.categoryId;
    _lastGender = event.gender;
    _lastLimit = event.limit ?? 20;

    final result = await searchSalonsUseCase(
      SearchSalonsParams(
        latitude: event.latitude,
        longitude: event.longitude,
        categoryId: event.categoryId,
        gender: event.gender,
        limit: event.limit ?? 20,
        page: 1,
      ),
    );

    result.fold(
      (failure) => emit(SearchFailure(_mapFailureToMessage(failure))),
      (salons) {
        if (salons.isEmpty) {
          emit(const SearchEmpty('No salons found with selected filters'));
        } else {
          emit(SearchLoaded(
            salons: salons,
            isSearchActive: true,
            categoryId: event.categoryId,
            gender: event.gender,
            currentPage: 1,
            hasMore: salons.length >= (event.limit ?? 20),
          ));
        }
      },
    );
  }

  Future<void> _onLoadMore(
    LoadMoreSalonsEvent event,
    Emitter<SearchState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SearchLoaded || !currentState.hasMore) return;

    emit(SearchLoadingMore(currentSalons: currentState.salons));

    // Use stored params with new page
    final result = currentState.isSearchActive
        ? await searchSalonsUseCase(
            SearchSalonsParams(
              latitude: _lastLatitude!,
              longitude: _lastLongitude!,
              query: _lastQuery,
              categoryId: _lastCategoryId,
              gender: _lastGender,
              limit: _lastLimit ?? 20,
              page: event.nextPage,
            ),
          )
        : await getNearbySalonsUseCase(
            GetNearbySalonsParams(
              latitude: _lastLatitude!,
              longitude: _lastLongitude!,
              gender: _lastGender,
              limit: _lastLimit ?? 20,
              page: event.nextPage,
            ),
          );

    result.fold(
      (failure) => emit(SearchFailure(_mapFailureToMessage(failure))),
      (newSalons) {
        final allSalons = [...currentState.salons, ...newSalons];
        emit(currentState.copyWith(
          salons: allSalons,
          currentPage: event.nextPage,
          hasMore: newSalons.length >= (_lastLimit ?? 20),
        ));
      },
    );
  }

  Future<void> _onClearSearch(
    ClearSearchEvent event,
    Emitter<SearchState> emit,
  ) async {
    // Return to nearby salons if we have last location
    if (_lastLatitude != null && _lastLongitude != null) {
      add(LoadNearbySalonsEvent(
        latitude: _lastLatitude!,
        longitude: _lastLongitude!,
        gender: _lastGender,
      ));
    } else {
      emit(const SearchInitial());
    }
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return failure.message;
    } else if (failure is ServerFailure) {
      return failure.message;
    } else {
      return 'An unexpected error occurred';
    }
  }
}
