import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/shared/domain/entities/salon_entity.dart';

/// Shared Salon Repository Interface
/// Used by Home, Explore, Category, Favorites, and other features
abstract class SalonRepository {
  /// Get salons with flexible filtering options
  /// All parameters except latitude and longitude are optional
  Future<Either<Failure, List<SalonEntity>>> getSalons({
    required double latitude,
    required double longitude,
    int? limit,
    int? page,
    String? gender,
    String? search,
    String? category,
    Map<String, dynamic>? filters,
  });

  /// Same query as [getSalons] but also returns the total match count.
  Future<Either<Failure, SalonPage>> getSalonsPage({
    required double latitude,
    required double longitude,
    int? limit,
    int? page,
    String? gender,
    String? search,
    String? category,
    Map<String, dynamic>? filters,
  });
}

/// One page of salons plus the total number of matches across all pages.
class SalonPage {
  final List<SalonEntity> salons;
  final int totalRecords;

  const SalonPage({required this.salons, required this.totalRecords});
}
