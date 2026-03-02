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
import 'package:tressy/features/category/domain/usecases/get_categories_usecase.dart' as category_usecase;
import 'package:tressy/features/category/presentation/bloc/category_bloc.dart';

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
}
