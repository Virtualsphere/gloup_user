import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:tressy/core/network/dio_client.dart';
import 'package:tressy/core/network/interceptor.dart';
import 'package:tressy/core/network/network_info.dart';
import 'package:tressy/core/network/network_info_impl.dart';
import 'package:tressy/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:tressy/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:tressy/features/auth/domain/repositories/auth_repository.dart';
import 'package:tressy/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:tressy/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:tressy/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tressy/features/category/data/datasources/category_remote_datasource.dart';
import 'package:tressy/features/category/data/repositories/category_repository_impl.dart';
import 'package:tressy/features/category/domain/repositories/category_repository.dart';
import 'package:tressy/features/category/domain/usecases/get_categories_usecase.dart'
    as category_usecase;
import 'package:tressy/features/category/presentation/bloc/category_bloc.dart';
import 'package:tressy/features/profile/data/datasources/profile_remote_datasources.dart';
import 'package:tressy/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:tressy/features/profile/domain/repositories/profile_repository.dart';
import 'package:tressy/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:tressy/features/profile/presentation/bloc/profile_bloc.dart';

// Shared Salon Repository
import 'package:tressy/shared/data/datasources/salon_remote_datasource.dart';
import 'package:tressy/shared/data/repositories/salon_repository_impl.dart';
import 'package:tressy/shared/domain/repositories/salon_repository.dart';
import 'package:tressy/shared/domain/usecases/get_salons_usecase.dart';
import 'package:tressy/features/home/data/datasources/home_datasource.dart';
import 'package:tressy/features/home/data/repositories/home_repository_impl.dart';
import 'package:tressy/features/home/domain/repositories/home_repository.dart';
import 'package:tressy/features/home/domain/usecases/get_carousel_banners_usecase.dart';
import 'package:tressy/features/home/domain/usecases/get_popular_services_usecase.dart';
import 'package:tressy/features/home/domain/usecases/get_top_salons_usecase.dart';
import 'package:tressy/features/home/presentation/bloc/home_bloc.dart';

// Explore Feature
import 'package:tressy/features/explore/presentation/bloc/explore_bloc.dart';
import 'package:tressy/features/salon_details/data/datasources/salon_detail_remote_datasource.dart';
import 'package:tressy/features/salon_details/data/repositories/salon_detail_repository_impl.dart';
import 'package:tressy/features/salon_details/domain/repositories/salon_detail_repository.dart';
import 'package:tressy/features/salon_details/domain/usecases/get_salon_details_usecase.dart';
import 'package:tressy/features/salon_details/presentation/bloc/salon_detail_bloc.dart';

// Favorites Feature
import 'package:tressy/features/favorites/data/datasources/favorites_remote_datasource.dart';
import 'package:tressy/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:tressy/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:tressy/features/favorites/domain/usecases/get_favorites_usecase.dart';
import 'package:tressy/features/favorites/domain/usecases/toggle_favorite_usecase.dart';
import 'package:tressy/features/favorites/presentation/bloc/favorites_bloc.dart';

// Slot Booking Feature
import 'package:tressy/features/slot_booking/data/datasources/slot_remote_datasource.dart';
import 'package:tressy/features/slot_booking/data/repositories/slot_repository_impl.dart';
import 'package:tressy/features/slot_booking/domain/repositories/slot_repository.dart';
import 'package:tressy/features/slot_booking/domain/usecases/get_slot_status_usecase.dart';
import 'package:tressy/features/slot_booking/presentation/bloc/slot_bloc.dart';

// Guest Feature
import 'package:tressy/features/booking_confirmation/data/datasources/guest_remote_datasource.dart';
import 'package:tressy/features/booking_confirmation/data/repositories/guest_repository_impl.dart';
import 'package:tressy/features/booking_confirmation/domain/repositories/guest_repository.dart';
import 'package:tressy/features/booking_confirmation/domain/usecases/get_all_guests_usecase.dart';
import 'package:tressy/features/booking_confirmation/domain/usecases/add_guest_usecase.dart';
import 'package:tressy/features/booking_confirmation/domain/usecases/update_guest_usecase.dart';
import 'package:tressy/features/booking_confirmation/presentation/bloc/guest_bloc.dart';

// Coupon Feature
import 'package:tressy/features/coupons/data/datasources/coupon_remote_datasource.dart';
import 'package:tressy/features/coupons/data/repositories/coupon_repository_impl.dart';
import 'package:tressy/features/coupons/domain/repositories/coupon_repository.dart';
import 'package:tressy/features/coupons/domain/usecases/get_active_coupons_usecase.dart';
import 'package:tressy/features/coupons/presentation/bloc/coupon_bloc.dart';

// Salon Search Feature
import 'package:tressy/features/salon_search/data/datasources/search_remote_datasource.dart';
import 'package:tressy/features/salon_search/data/repositories/search_repository_impl.dart';
import 'package:tressy/features/salon_search/domain/repositories/search_repository.dart';
import 'package:tressy/features/salon_search/domain/usecases/get_nearby_salons_usecase.dart';
import 'package:tressy/features/salon_search/domain/usecases/search_salons_usecase.dart';
import 'package:tressy/features/salon_search/presentation/bloc/search_bloc.dart';
import 'package:tressy/features/salon_search/domain/usecases/get_clustered_markers_usecase.dart';
import 'package:tressy/features/salon_search/presentation/bloc/map_markers_bloc.dart';

final sl = GetIt.instance;

/// Initialize dependencies
Future<void> initializeDependencies() async {
  // ==================== Core ====================

  // Network
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<LoggerInterceptor>(() => LoggerInterceptor());
  sl.registerLazySingleton<DioClient>(() => DioClient());

  // ==================== Features ====================

  // Auth Feature
  // BLoC
  sl.registerFactory<AuthBloc>(() => AuthBloc(
        sendOtpUseCase: sl(),
        verifyOtpUseCase: sl(),
      ));

  // Use Cases
  sl.registerLazySingleton<SendOtpUseCase>(() => SendOtpUseCase(sl()));
  sl.registerLazySingleton<VerifyOtpUseCase>(() => VerifyOtpUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  // Shared Salon Repository (Used by Home, Explore, Favorites, etc.)
  // Data Sources
  sl.registerLazySingleton<SalonRemoteDataSource>(
    () => SalonRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<SalonRepository>(
    () => SalonRepositoryImpl(sl()),
  );

  // Use Cases
  sl.registerLazySingleton<GetSalonsUseCase>(
    () => GetSalonsUseCase(sl()),
  );

  // Category Feature
  // BLoC - Registered as singleton to share state across screens
  sl.registerLazySingleton<CategoryBloc>(() => CategoryBloc(
        getCategoriesUseCase: sl(),
        getSalonsUseCase: sl(), // Using shared use case
      ));

  // Use Cases
  sl.registerLazySingleton<category_usecase.GetCategoriesUseCase>(
    () => category_usecase.GetCategoriesUseCase(sl()),
  );

  // Repository
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(sl()),
  );

  // Data Sources
  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(sl()),
  );

  // Home Feature
  // BLoC
  sl.registerFactory<HomeBloc>(() => HomeBloc(
        getCarouselBannersUseCase: sl(),
        getPopularServicesUseCase: sl(),
        getTopSalonsUseCase: sl(),
        getSalonsUseCase: sl(), // Using shared use case
      ));

  // Explore Feature
  // BLoC
  sl.registerFactory<ExploreBloc>(() => ExploreBloc(
        getSalonsUseCase: sl(), // Using shared use case
      ));

  // Use Cases
  sl.registerLazySingleton<GetCarouselBannersUseCase>(
    () => GetCarouselBannersUseCase(sl()),
  );
  sl.registerLazySingleton<GetPopularServicesUseCase>(
    () => GetPopularServicesUseCase(sl()),
  );
  sl.registerLazySingleton<GetTopSalonsUseCase>(
    () => GetTopSalonsUseCase(sl()),
  );
  // GetRecommendedSalonsUseCase removed - now using shared GetSalonsUseCase

  // Repository
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(sl()),
  );

  // Data Sources
  sl.registerLazySingleton<HomeDataSource>(
    () => HomeDataSourceImpl(sl()),
  );

  // Salon Details Feature
  // BLoC
  sl.registerFactory<SalonDetailBloc>(() => SalonDetailBloc(
        getSalonDetailsUseCase: sl(),
      ));

  // Use Cases
  sl.registerLazySingleton<GetSalonDetailsUseCase>(
    () => GetSalonDetailsUseCase(sl()),
  );

  // Repository
  sl.registerLazySingleton<SalonDetailRepository>(
    () => SalonDetailRepositoryImpl(sl()),
  );

  // Data Sources
  sl.registerLazySingleton<SalonDetailRemoteDataSource>(
    () => SalonDetailRemoteDataSourceImpl(sl()),
  );

  // Favorites Feature
  // BLoC - Registered as singleton to share favorite state across the app
  sl.registerLazySingleton<FavoritesBloc>(() => FavoritesBloc(
        toggleFavoriteUseCase: sl(),
        getFavoritesUseCase: sl(),
      ));

  // Use Cases
  sl.registerLazySingleton<ToggleFavoriteUseCase>(
    () => ToggleFavoriteUseCase(sl()),
  );

  sl.registerLazySingleton<GetFavoritesUseCase>(
    () => GetFavoritesUseCase(sl()),
  );

  // Repository
  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<FavoritesRemoteDataSource>(
    () => FavoritesRemoteDataSourceImpl(sl()),
  );

  // Slot Booking Feature
  // BLoC - Factory for new instance each time
  sl.registerFactory<SlotBloc>(() => SlotBloc(
        getSlotStatusUseCase: sl(),
      ));

  // Use Cases
  sl.registerLazySingleton<GetSlotStatusUseCase>(
    () => GetSlotStatusUseCase(sl()),
  );

  // Repository
  sl.registerLazySingleton<SlotRepository>(
    () => SlotRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<SlotRemoteDataSource>(
    () => SlotRemoteDataSourceImpl(sl()),
  );

  // ─── Profile ───────────────────────────────────────
// DataSource
  sl.registerLazySingleton<ProfileRemoteDataSource>(
        () => ProfileRemoteDataSourceImpl(sl()),
  );

// Repository
  sl.registerLazySingleton<ProfileRepository>(
        () => ProfileRepositoryImpl(sl()),
  );

// UseCases
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));

// Bloc
  sl.registerFactory(() => ProfileBloc(
    getProfileUseCase: sl(),
    updateProfileUseCase: sl(),
  ));
  // Guest Feature
  // BLoC - Factory for new instance each time
  sl.registerFactory<GuestBloc>(() => GuestBloc(
        getAllGuestsUseCase: sl(),
        addGuestUseCase: sl(),
        updateGuestUseCase: sl(),
      ));

  // Use Cases
  sl.registerLazySingleton<GetAllGuestsUseCase>(
    () => GetAllGuestsUseCase(sl()),
  );
  
  sl.registerLazySingleton<AddGuestUseCase>(
    () => AddGuestUseCase(sl()),
  );
  
  sl.registerLazySingleton<UpdateGuestUseCase>(
    () => UpdateGuestUseCase(sl()),
  );

  // Repository
  sl.registerLazySingleton<GuestRepository>(
    () => GuestRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<GuestRemoteDataSource>(
    () => GuestRemoteDataSourceImpl(sl()),
  );

  // Coupon Feature
  // BLoC - Factory for new instance each time
  sl.registerFactory<CouponBloc>(() => CouponBloc(
        getActiveCouponsUseCase: sl(),
      ));

  // Use Cases
  sl.registerLazySingleton<GetActiveCouponsUseCase>(
    () => GetActiveCouponsUseCase(sl()),
  );

  // Repository
  sl.registerLazySingleton<CouponRepository>(
    () => CouponRepositoryImpl(sl()),
  );

  // Data Sources
  sl.registerLazySingleton<CouponRemoteDataSource>(
    () => CouponRemoteDataSourceImpl(sl()),
  );

  // Salon Search Feature
  // BLoC - Factory for new instance each time
  // SearchBloc - ONLY for bottom sheet salon list
  sl.registerFactory<SearchBloc>(() => SearchBloc(
        getNearbySalonsUseCase: sl(),
        searchSalonsUseCase: sl(),
      ));

  // MapMarkersBloc - ONLY for map markers
  sl.registerFactory<MapMarkersBloc>(() => MapMarkersBloc(
        getClusteredMarkersUseCase: sl(),
      ));

  // Use Cases
  sl.registerLazySingleton<GetNearbySalonsUseCase>(
    () => GetNearbySalonsUseCase(sl()),
  );

  sl.registerLazySingleton<SearchSalonsUseCase>(
    () => SearchSalonsUseCase(sl()),
  );

  sl.registerLazySingleton<GetClusteredMarkersUseCase>(
    () => GetClusteredMarkersUseCase(sl()),
  );

  // Repository
  sl.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(sl()),
  );

  // Data Sources
  sl.registerLazySingleton<SearchRemoteDataSource>(
    () => SearchRemoteDataSourceImpl(
      homeDataSource: sl(),
      salonDataSource: sl(),
      dioClient: sl(),
    ),
  );

}
