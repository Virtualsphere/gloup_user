import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/home/domain/usecases/get_carousel_banners_usecase.dart';
import 'package:tressy/features/home/domain/usecases/get_popular_services_usecase.dart';
import 'package:tressy/features/home/domain/usecases/get_top_salons_usecase.dart';
import 'package:tressy/features/home/domain/usecases/get_recommended_salons_usecase.dart';
import 'package:tressy/features/home/presentation/bloc/home_event.dart';
import 'package:tressy/features/home/presentation/bloc/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetCarouselBannersUseCase getCarouselBannersUseCase;
  final GetPopularServicesUseCase getPopularServicesUseCase;
  final GetTopSalonsUseCase getTopSalonsUseCase;
  final GetRecommendedSalonsUseCase getRecommendedSalonsUseCase;

  HomeBloc({
    required this.getCarouselBannersUseCase,
    required this.getPopularServicesUseCase,
    required this.getTopSalonsUseCase,
    required this.getRecommendedSalonsUseCase,
  }) : super(const HomeState()) {
    on<LoadCarouselBannersEvent>(_onLoadCarouselBanners);
    on<LoadPopularServicesEvent>(_onLoadPopularServices);
    on<LoadTopSalonsEvent>(_onLoadTopSalons);
    on<LoadRecommendedSalonsEvent>(_onLoadRecommendedSalons);
    on<LoadAllHomeDataEvent>(_onLoadAllHomeData);
    on<ResetHomeEvent>(_onResetHome);
  }

  Future<void> _onLoadCarouselBanners(
    LoadCarouselBannersEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(
      isCarouselLoading: true,
      clearCarouselError: true,
    ));

    final result = await getCarouselBannersUseCase();

    result.fold(
      (failure) => emit(state.copyWith(
        isCarouselLoading: false,
        carouselError: _mapFailureToMessage(failure),
      )),
      (banners) => emit(state.copyWith(
        isCarouselLoading: false,
        carouselBanners: banners,
        clearCarouselError: true,
      )),
    );
  }

  Future<void> _onLoadPopularServices(
    LoadPopularServicesEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(
      isPopularServicesLoading: true,
      clearPopularServicesError: true,
    ));

    final result = await getPopularServicesUseCase(
      GetPopularServicesParams(
        latitude: event.latitude,
        longitude: event.longitude,
        limit: event.limit,
        page: event.page,
        gender: event.gender,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isPopularServicesLoading: false,
        popularServicesError: _mapFailureToMessage(failure),
      )),
      (salons) => emit(state.copyWith(
        isPopularServicesLoading: false,
        popularServices: salons,
        clearPopularServicesError: true,
      )),
    );
  }

  Future<void> _onLoadTopSalons(
    LoadTopSalonsEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(
      isTopSalonsLoading: true,
      clearTopSalonsError: true,
    ));

    final result = await getTopSalonsUseCase(
      GetTopSalonsParams(
        latitude: event.latitude,
        longitude: event.longitude,
        limit: event.limit,
        page: event.page,
        gender: event.gender,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isTopSalonsLoading: false,
        topSalonsError: _mapFailureToMessage(failure),
      )),
      (salons) => emit(state.copyWith(
        isTopSalonsLoading: false,
        topSalons: salons,
        clearTopSalonsError: true,
      )),
    );
  }

  Future<void> _onLoadRecommendedSalons(
    LoadRecommendedSalonsEvent event,
    Emitter<HomeState> emit,
  ) async {
    // Don't load more if already loading or no more data
    if (event.isLoadMore) {
      if (state.isLoadingMoreRecommended || !state.hasMoreRecommended) {
        return;
      }
      emit(state.copyWith(isLoadingMoreRecommended: true));
    } else {
      emit(state.copyWith(
        isRecommendedSalonsLoading: true,
        clearRecommendedSalonsError: true,
      ));
    }

    final result = await getRecommendedSalonsUseCase(
      GetRecommendedSalonsParams(
        latitude: event.latitude,
        longitude: event.longitude,
        limit: event.limit ?? 10,
        page: event.page ?? (event.isLoadMore ? state.recommendedCurrentPage + 1 : 1),
        gender: event.gender,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isRecommendedSalonsLoading: false,
        isLoadingMoreRecommended: false,
        recommendedSalonsError: _mapFailureToMessage(failure),
      )),
      (salons) {
        // For load more, append to existing list; otherwise replace
        final updatedSalons = event.isLoadMore 
            ? [...state.recommendedSalons, ...salons]
            : salons;
        
        // Calculate pagination info from response
        // Note: We need to get this from the repository response
        // For now, we'll use the page from the request
        final currentPage = event.page ?? (event.isLoadMore ? state.recommendedCurrentPage + 1 : 1);
        final hasMore = salons.length >= (event.limit ?? 10);
        
        emit(state.copyWith(
          isRecommendedSalonsLoading: false,
          isLoadingMoreRecommended: false,
          recommendedSalons: updatedSalons,
          clearRecommendedSalonsError: true,
          recommendedCurrentPage: currentPage,
          hasMoreRecommended: hasMore,
        ));
      },
    );
  }

  Future<void> _onLoadAllHomeData(
    LoadAllHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    // Load all data simultaneously (categories now handled by CategoryBloc)
    add(const LoadCarouselBannersEvent());
    add(LoadPopularServicesEvent(
      latitude: event.latitude,
      longitude: event.longitude,
      limit: 10, // Set limit to 10 for home screen
    ));
    add(LoadTopSalonsEvent(
      latitude: event.latitude,
      longitude: event.longitude,
      limit: 10, // Set limit to 10 for home screen
    ));
    add(LoadRecommendedSalonsEvent(
      latitude: event.latitude,
      longitude: event.longitude,
      limit: 10, // Set limit to 10 for home screen
      page: 1,
    ));
  }

  void _onResetHome(ResetHomeEvent event, Emitter<HomeState> emit) {
    emit(const HomeState());
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
