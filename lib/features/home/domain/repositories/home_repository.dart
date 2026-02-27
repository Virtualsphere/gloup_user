import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/home/domain/entities/home_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<CarouselBannerEntity>>> getCarouselBanners();
  
  Future<Either<Failure, List<SalonEntity>>> getPopularServices({
    required double latitude,
    required double longitude,
    int? limit,
    int? page,
    String? gender,
  });
  
  Future<Either<Failure, List<SalonEntity>>> getTopSalons({
    required double latitude,
    required double longitude,
    int? limit,
    int? page,
    String? gender,
  });
  
  Future<Either<Failure, List<SalonEntity>>> getRecommendedSalons({
    required double latitude,
    required double longitude,
    int? limit,
    int? page,
    String? gender,
  });
}
