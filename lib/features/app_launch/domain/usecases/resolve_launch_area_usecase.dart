import 'package:tressy/features/app_launch/domain/repositories/app_launch_repository.dart';

class ResolveLaunchAreaUseCase {
  final AppLaunchRepository repository;

  ResolveLaunchAreaUseCase(this.repository);

  Future<String> call() async {
    return await repository.resolveCurrentArea();
  }
}

