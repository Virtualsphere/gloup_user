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
import 'package:tressy/features/home/data/datasources/home_datasource.dart';
import 'package:tressy/features/home/data/repositories/home_repository_impl.dart';
import 'package:tressy/features/home/domain/repositories/home_repository.dart';
import 'package:tressy/features/home/domain/usecases/get_carousel_banners_usecase.dart';
import 'package:tressy/features/home/domain/usecases/get_categories_usecase.dart';
import 'package:tressy/features/home/domain/usecases/get_popular_services_usecase.dart';
import 'package:tressy/features/home/domain/usecases/get_recommended_salons_usecase.dart';
import 'package:tressy/features/home/domain/usecases/get_top_salons_usecase.dart';
import 'package:tressy/features/home/presentation/bloc/home_bloc.dart';

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

  // Home Feature
  // BLoC
  sl.registerFactory<HomeBloc>(() => HomeBloc(
        getCarouselBannersUseCase: sl(),
        getCategoriesUseCase: sl(),
        getPopularServicesUseCase: sl(),
        getTopSalonsUseCase: sl(),
        getRecommendedSalonsUseCase: sl(),
      ));

  // Use Cases
  sl.registerLazySingleton<GetCarouselBannersUseCase>(
    () => GetCarouselBannersUseCase(sl()),
  );
  sl.registerLazySingleton<GetCategoriesUseCase>(
    () => GetCategoriesUseCase(sl()),
  );
  sl.registerLazySingleton<GetPopularServicesUseCase>(
    () => GetPopularServicesUseCase(sl()),
  );
  sl.registerLazySingleton<GetTopSalonsUseCase>(
    () => GetTopSalonsUseCase(sl()),
  );
  sl.registerLazySingleton<GetRecommendedSalonsUseCase>(
    () => GetRecommendedSalonsUseCase(sl()),
  );

  // Repository
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(sl()),
  );

  // Data Sources
  sl.registerLazySingleton<HomeDataSource>(
    () => HomeDataSourceImpl(),
  );
}
