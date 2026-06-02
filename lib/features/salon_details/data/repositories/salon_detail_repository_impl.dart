import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/core/network/api_exception.dart';
import 'package:tressy/features/salon_details/data/datasources/salon_detail_remote_datasource.dart';
import 'package:tressy/features/salon_details/domain/entities/salon_detail_entity.dart';
import 'package:tressy/features/salon_details/domain/repositories/salon_detail_repository.dart';

class SalonDetailRepositoryImpl implements SalonDetailRepository {
  final SalonDetailRemoteDataSource remoteDataSource;

  SalonDetailRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, SalonDetailEntity>> getSalonDetails({
    required String salonId,
  }) async {
    try {
      final model = await remoteDataSource.getSalonDetails(salonId: salonId);

      // Map model to entity
      final entity = SalonDetailEntity(
        id: model.id,
        name: model.name,
        isNew: model.isNew,
        isPremium: model.isPremium,
        rating: model.rating,
        reviewCount: model.reviewCount,
        gender: model.gender,
        address: model.address,
        isOpen: model.isOpen,
        openingTime: model.openingTime,
        closingTime: model.closingTime,
        languages: model.languages,
        images: model.images,
        about: model.about,
        services: model.services
            .map((s) => ServiceEntity(
                  id: s.id,
                  name: s.name,
                  duration: s.duration,
                  price: s.price,
                  originalPrice: s.originalPrice,
                  discountPercentage: s.discountPercentage,
                  isPopular: s.isPopular,
                  category: s.category,
                  serviceFor: s.serviceFor,
                ))
            .toList(),
        ambients: model.ambients
            .map((a) => AmbientEntity(
                  id: a.id,
                  icon: a.icon,
                  label: a.label,
                ))
            .toList(),
        teamMembers: model.teamMembers
            .map((t) => TeamMemberEntity(
                  id: t.id,
                  name: t.name,
                  role: t.role,
                  imageUrl: t.imageUrl,
                ))
            .toList(),
        reviews: model.reviews
            .map((r) => ReviewEntity(
                  id: r.id,
                  userName: r.userName,
                  userImage: r.userImage,
                  timeAgo: r.timeAgo,
                  rating: r.rating,
                  reviewText: r.reviewText,
                ))
            .toList(),
        openingHours: model.openingHours,
        location: LocationEntity(
          latitude: model.location.latitude,
          longitude: model.location.longitude,
          address: model.location.address,
        ),
      );

      return Right(entity);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
          ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }
}
