import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:tressy/core/network/dio_client.dart';
import 'package:tressy/core/network/interceptor.dart';
import 'package:tressy/core/network/network_info.dart';
import 'package:tressy/core/network/network_info_impl.dart';
import 'package:tressy/features/example/data/datasources/example_remote_datasource.dart';
import 'package:tressy/features/example/data/repositories/example_repository_impl.dart';
import 'package:tressy/features/example/domain/repositories/example_repository.dart';
import 'package:tressy/features/example/domain/usecases/get_examples_usecase.dart';
import 'package:tressy/features/example/presentation/bloc/example_bloc.dart';

/// Dependency injection container
final sl = GetIt.instance;

/// Initialize dependencies
Future<void> initializeDependencies() async {
  // ==================== Core ====================
  
  // Network
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<LoggerInterceptor>(() => LoggerInterceptor());
  sl.registerLazySingleton<DioClient>(() => DioClient());

  // ==================== Example Feature ====================
  
  // Data sources
  sl.registerLazySingleton<ExampleRemoteDataSource>(
    () => ExampleRemoteDataSourceImpl(dioClient: sl()),
  );

  // Repositories
  sl.registerLazySingleton<ExampleRepository>(
    () => ExampleRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetExamplesUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => ExampleBloc(getExamplesUseCase: sl()),
  );
}
