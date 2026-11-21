import 'package:tressy/features/app_launch/domain/repositories/app_launch_repository.dart';

class CheckLaunchStatusUseCase {
  final AppLaunchRepository repository;

  CheckLaunchStatusUseCase(this.repository);

  Future<bool> call() async {
    return await repository.isFirstOpen();
  }
}

