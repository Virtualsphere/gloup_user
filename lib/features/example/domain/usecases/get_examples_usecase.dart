import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/example_entity.dart';
import '../repositories/example_repository.dart';

/// Get examples use case - Domain layer
class GetExamplesUseCase {
  final ExampleRepository repository;

  GetExamplesUseCase(this.repository);

  Future<Either<Failure, List<ExampleEntity>>> call() async {
    return await repository.getExamples();
  }
}
