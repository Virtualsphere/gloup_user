import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:tressy/core/providers/location_provider.dart';
import 'package:tressy/core/theme/app_theme.dart';
import 'package:tressy/core/theme/theme_provider.dart';
import 'package:tressy/features/auth/presentation/bloc/auth_event.dart';
import 'package:tressy/features/category/presentation/bloc/category_bloc.dart';
import 'package:tressy/features/category/presentation/bloc/category_event.dart';
import 'package:tressy/features/category/presentation/bloc/category_state.dart';
import 'package:tressy/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:tressy/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:tressy/features/favorites/presentation/bloc/favorites_state.dart';
import 'package:tressy/features/home/presentation/bloc/home_bloc.dart';
import 'package:tressy/features/home/presentation/bloc/home_event.dart';
import 'package:tressy/features/home/presentation/bloc/home_state.dart';
import 'package:tressy/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:tressy/features/profile/presentation/bloc/profile_event.dart';
import 'package:tressy/features/profile/presentation/bloc/profile_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tressy/core/utils/local_storage_service.dart';

class MockProfileBloc extends Mock implements ProfileBloc {}

class MockFavoritesBloc extends Mock implements FavoritesBloc {}

class MockCategoryBloc extends Mock implements CategoryBloc {}

class MockHomeBloc extends Mock implements HomeBloc {}

void registerWidgetTestFallbacks() {
  registerFallbackValue(const SendOtpEvent('0000000000'));
  registerFallbackValue(
    const LoadAllHomeDataEvent(latitude: 13.0827, longitude: 80.2707),
  );
  registerFallbackValue(const GetProfileEvent());
  registerFallbackValue(const LoadFavoritesEvent());
  registerFallbackValue(const LoadCategoriesEvent());
}

Future<void> initWidgetTestStorage({
  Map<String, Object> preferences = const {},
}) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  const secureStorageChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(secureStorageChannel, (call) async {
    switch (call.method) {
      case 'read':
        return null;
      case 'write':
      case 'delete':
      case 'deleteAll':
        return null;
      default:
        return null;
    }
  });
  SharedPreferences.setMockInitialValues(preferences);
  await LocalStorageService.init();
}

void setWidgetTestScreenSize(WidgetTester tester, {Size size = const Size(600, 900)}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Wraps [child] with [MaterialApp] and light theme for widget tests.
Widget buildTestMaterialApp({
  required Widget child,
  ThemeProvider? themeProvider,
}) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (context, _) {
      return ChangeNotifierProvider(
        create: (_) => themeProvider ?? ThemeProvider(),
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: child,
        ),
      );
    },
  );
}

/// Home screen dependencies used by [HomePage].
Widget buildHomePageTestHarness({
  required HomeBloc homeBloc,
  required Widget child,
  ProfileBloc? profileBloc,
  FavoritesBloc? favoritesBloc,
  CategoryBloc? categoryBloc,
  LocationProvider? locationProvider,
}) {
  final profile = profileBloc ?? _defaultProfileBloc();
  final favorites = favoritesBloc ?? _defaultFavoritesBloc();
  final category = categoryBloc ?? _defaultCategoryBloc();

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<LocationProvider>(
        create: (_) => locationProvider ?? LocationProvider(),
      ),
    ],
    child: MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>.value(value: homeBloc),
        BlocProvider<ProfileBloc>.value(value: profile),
        BlocProvider<FavoritesBloc>.value(value: favorites),
        BlocProvider<CategoryBloc>.value(value: category),
      ],
      child: buildTestMaterialApp(child: child),
    ),
  );
}

HomeState homeLoadingState() => const HomeState(
      isCarouselLoading: true,
      isPopularServicesLoading: true,
      isTopSalonsLoading: true,
      isRecommendedSalonsLoading: true,
    );

void stubBlocBase<C extends BlocBase<S>, S>(C bloc, S state) {
  when(() => bloc.state).thenReturn(state);
  when(() => bloc.stream).thenAnswer((_) => Stream.value(state));
  when(() => bloc.close()).thenAnswer((_) async {});
}

ProfileBloc _defaultProfileBloc() {
  final bloc = MockProfileBloc();
  stubBlocBase<ProfileBloc, ProfileState>(bloc, const ProfileInitial());
  when(() => bloc.add(any())).thenReturn(null);
  return bloc;
}

FavoritesBloc _defaultFavoritesBloc() {
  final bloc = MockFavoritesBloc();
  stubBlocBase<FavoritesBloc, FavoritesState>(bloc, const FavoritesState());
  when(() => bloc.add(any())).thenReturn(null);
  return bloc;
}

CategoryBloc _defaultCategoryBloc() {
  final bloc = MockCategoryBloc();
  stubBlocBase<CategoryBloc, CategoryState>(bloc, const CategoryState());
  when(() => bloc.add(any())).thenReturn(null);
  return bloc;
}

void stubHomeBlocLoading(MockHomeBloc bloc) {
  final state = homeLoadingState();
  stubBlocBase<HomeBloc, HomeState>(bloc, state);
  when(() => bloc.add(any())).thenReturn(null);
}
