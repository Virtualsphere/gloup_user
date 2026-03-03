import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/salon_search/domain/repositories/search_repository.dart';
import 'package:tressy/shared/domain/entities/salon_entity.dart';

class SearchSalonsParams {
  final double latitude;
  final double longitude;
  final String? query;
  final String? categoryId;
  final String? gender;
  final int? limit;
  final int? page;

  SearchSalonsParams({
    required this.latitude,
    required this.longitude,
    this.query,
    this.categoryId,
    this.gender,
    this.limit,
    this.page,
  });
}

class SearchSalonsUseCase {
  final SearchRepository repository;

  SearchSalonsUseCase(this.repository);

  Future<Either<Failure, List<SalonEntity>>> call(
    SearchSalonsParams params,
  ) async {
    return await repository.searchSalons(
      latitude: params.latitude,
      longitude: params.longitude,
      query: params.query,
      categoryId: params.categoryId,
      gender: params.gender,
      limit: params.limit,
      page: params.page,
    );
  }
}
