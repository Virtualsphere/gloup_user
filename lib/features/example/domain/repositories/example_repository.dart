import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/example_entity.dart';

/// Example repository interface - Domain layer
abstract class ExampleRepository {
  Future<Either<Failure, List<ExampleEntity>>> getExamples();
  Future<Either<Failure, ExampleEntity>> getExampleById(String id);
  Future<Either<Failure, ExampleEntity>> createExample(ExampleEntity example);
  Future<Either<Failure, ExampleEntity>> updateExample(ExampleEntity example);
  Future<Either<Failure, void>> deleteExample(String id);
}
