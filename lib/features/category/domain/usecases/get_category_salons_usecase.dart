import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/category/domain/entities/category_salon_entity.dart';
import 'package:tressy/features/category/domain/repositories/category_repository.dart';

class GetCategorySalonsUseCase {
  final CategoryRepository repository;

  GetCategorySalonsUseCase(this.repository);

  Future<Either<Failure, List<CategorySalonEntity>>> call(
    GetCategorySalonsParams params,
  ) async {
    return await repository.getCategorySalons(
      latitude: params.latitude,
      longitude: params.longitude,
      categoryId: params.categoryId,
      limit: params.limit,
      page: params.page,
      gender: params.gender,
      search: params.search,
    );
  }
}

class GetCategorySalonsParams {
  final double latitude;
  final double longitude;
  final String categoryId;
  final int? limit;
  final int? page;
  final String? gender;
  final String? search;

  GetCategorySalonsParams({
    required this.latitude,
    required this.longitude,
    required this.categoryId,
    this.limit,
    this.page,
    this.gender,
    this.search,
  });
}
