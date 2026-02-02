import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/example_entity.dart';
import '../../domain/repositories/example_repository.dart';
import '../datasources/example_remote_datasource.dart';

/// Example repository implementation - Data layer
class ExampleRepositoryImpl implements ExampleRepository {
  final ExampleRemoteDataSource remoteDataSource;

  ExampleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ExampleEntity>>> getExamples() async {
    try {
      final result = await remoteDataSource.getExamples();
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExampleEntity>> getExampleById(String id) async {
    try {
      final result = await remoteDataSource.getExampleById(id);
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExampleEntity>> createExample(ExampleEntity example) async {
    try {
      final model = await remoteDataSource.createExample(
        _entityToModel(example),
      );
      return Right(model);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExampleEntity>> updateExample(ExampleEntity example) async {
    try {
      final model = await remoteDataSource.updateExample(
        _entityToModel(example),
      );
      return Right(model);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExample(String id) async {
    try {
      await remoteDataSource.deleteExample(id);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // Helper method to convert entity to model
  dynamic _entityToModel(ExampleEntity entity) {
    // Import ExampleModel here if needed
    return entity;
  }
}
