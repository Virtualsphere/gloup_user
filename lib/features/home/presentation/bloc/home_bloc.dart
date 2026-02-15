import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/home/domain/usecases/get_carousel_banners_usecase.dart';
import 'package:tressy/features/home/domain/usecases/get_categories_usecase.dart';
import 'package:tressy/features/home/domain/usecases/get_popular_services_usecase.dart';
import 'package:tressy/features/home/domain/usecases/get_top_salons_usecase.dart';
import 'package:tressy/features/home/domain/usecases/get_recommended_salons_usecase.dart';
import 'package:tressy/features/home/presentation/bloc/home_event.dart';
import 'package:tressy/features/home/presentation/bloc/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetCarouselBannersUseCase getCarouselBannersUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetPopularServicesUseCase getPopularServicesUseCase;
  final GetTopSalonsUseCase getTopSalonsUseCase;
  final GetRecommendedSalonsUseCase getRecommendedSalonsUseCase;

  HomeBloc({
    required this.getCarouselBannersUseCase,
    required this.getCategoriesUseCase,
    required this.getPopularServicesUseCase,
    required this.getTopSalonsUseCase,
    required this.getRecommendedSalonsUseCase,
  }) : super(const HomeState()) {
    on<LoadCarouselBannersEvent>(_onLoadCarouselBanners);
    on<LoadCategoriesEvent>(_onLoadCategories);
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

  Future<void> _onLoadCategories(
    LoadCategoriesEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(
      isCategoriesLoading: true,
      clearCategoriesError: true,
    ));

    final result = await getCategoriesUseCase();

    result.fold(
      (failure) => emit(state.copyWith(
        isCategoriesLoading: false,
        categoriesError: _mapFailureToMessage(failure),
      )),
      (categories) => emit(state.copyWith(
        isCategoriesLoading: false,
        categories: categories,
        clearCategoriesError: true,
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
    emit(state.copyWith(
      isRecommendedSalonsLoading: true,
      clearRecommendedSalonsError: true,
    ));

    final result = await getRecommendedSalonsUseCase();

    result.fold(
      (failure) => emit(state.copyWith(
        isRecommendedSalonsLoading: false,
        recommendedSalonsError: _mapFailureToMessage(failure),
      )),
      (salons) => emit(state.copyWith(
        isRecommendedSalonsLoading: false,
        recommendedSalons: salons,
        clearRecommendedSalonsError: true,
      )),
    );
  }

  Future<void> _onLoadAllHomeData(
    LoadAllHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    // Load all data simultaneously
    add(const LoadCarouselBannersEvent());
    add(const LoadCategoriesEvent());
    add(LoadPopularServicesEvent(
      latitude: event.latitude,
      longitude: event.longitude,
    ));
    add(LoadTopSalonsEvent(
      latitude: event.latitude,
      longitude: event.longitude,
    ));
    add(const LoadRecommendedSalonsEvent());
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
