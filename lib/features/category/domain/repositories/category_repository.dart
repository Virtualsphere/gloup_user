import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/category/domain/entities/category_entity.dart';
import 'package:tressy/shared/domain/entities/salon_entity.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<CategoryEntity>>> getCategories();
  Future<Either<Failure, List<SalonEntity>>> getCategorySalons({
    required double latitude,
    required double longitude,
    required String categoryId,
    int? limit,
    int? page,
    String? gender,
    String? search,
  });
}
