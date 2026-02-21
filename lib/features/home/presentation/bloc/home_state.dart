import 'package:equatable/equatable.dart';
import 'package:tressy/features/home/domain/entities/home_entity.dart';

class HomeState extends Equatable {
  // Carousel Banners
  final bool isCarouselLoading;
  final List<CarouselBannerEntity> carouselBanners;
  final String? carouselError;

  // Popular Services
  final bool isPopularServicesLoading;
  final List<SalonEntity> popularServices;
  final String? popularServicesError;

  // Top Salons
  final bool isTopSalonsLoading;
  final List<SalonEntity> topSalons;
  final String? topSalonsError;

  // Recommended Salons
  final bool isRecommendedSalonsLoading;
  final List<SalonEntity> recommendedSalons;
  final String? recommendedSalonsError;

  const HomeState({
    this.isCarouselLoading = false,
    this.carouselBanners = const [],
    this.carouselError,
    this.isPopularServicesLoading = false,
    this.popularServices = const [],
    this.popularServicesError,
    this.isTopSalonsLoading = false,
    this.topSalons = const [],
    this.topSalonsError,
    this.isRecommendedSalonsLoading = false,
    this.recommendedSalons = const [],
    this.recommendedSalonsError,
  });

  HomeState copyWith({
    bool? isCarouselLoading,
    List<CarouselBannerEntity>? carouselBanners,
    String? carouselError,
    bool clearCarouselError = false,
    bool? isPopularServicesLoading,
    List<SalonEntity>? popularServices,
    String? popularServicesError,
    bool clearPopularServicesError = false,
    bool? isTopSalonsLoading,
    List<SalonEntity>? topSalons,
    String? topSalonsError,
    bool clearTopSalonsError = false,
    bool? isRecommendedSalonsLoading,
    List<SalonEntity>? recommendedSalons,
    String? recommendedSalonsError,
    bool clearRecommendedSalonsError = false,
  }) {
    return HomeState(
      isCarouselLoading: isCarouselLoading ?? this.isCarouselLoading,
      carouselBanners: carouselBanners ?? this.carouselBanners,
      carouselError: clearCarouselError ? null : (carouselError ?? this.carouselError),
      isPopularServicesLoading: isPopularServicesLoading ?? this.isPopularServicesLoading,
      popularServices: popularServices ?? this.popularServices,
      popularServicesError: clearPopularServicesError ? null : (popularServicesError ?? this.popularServicesError),
      isTopSalonsLoading: isTopSalonsLoading ?? this.isTopSalonsLoading,
      topSalons: topSalons ?? this.topSalons,
      topSalonsError: clearTopSalonsError ? null : (topSalonsError ?? this.topSalonsError),
      isRecommendedSalonsLoading: isRecommendedSalonsLoading ?? this.isRecommendedSalonsLoading,
      recommendedSalons: recommendedSalons ?? this.recommendedSalons,
      recommendedSalonsError: clearRecommendedSalonsError ? null : (recommendedSalonsError ?? this.recommendedSalonsError),
    );
  }

  /// Check if any data is loading
  bool get isAnyLoading =>
      isCarouselLoading ||
      isPopularServicesLoading ||
      isTopSalonsLoading ||
      isRecommendedSalonsLoading;

  /// Check if all data has loaded successfully
  bool get hasAllData =>
      carouselBanners.isNotEmpty &&
      popularServices.isNotEmpty &&
      topSalons.isNotEmpty &&
      recommendedSalons.isNotEmpty;

  @override
  List<Object?> get props => [
        isCarouselLoading,
        carouselBanners,
        carouselError,
        isPopularServicesLoading,
        popularServices,
        popularServicesError,
        isTopSalonsLoading,
        topSalons,
        topSalonsError,
        isRecommendedSalonsLoading,
        recommendedSalons,
        recommendedSalonsError,
      ];
}
