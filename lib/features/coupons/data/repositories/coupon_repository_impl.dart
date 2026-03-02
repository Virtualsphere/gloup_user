import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/core/network/api_exception.dart';
import 'package:tressy/features/coupons/data/datasources/coupon_remote_datasource.dart';
import 'package:tressy/features/coupons/domain/entities/coupon_entity.dart';
import 'package:tressy/features/coupons/domain/repositories/coupon_repository.dart';

class CouponRepositoryImpl implements CouponRepository {
  final CouponRemoteDataSource dataSource;

  CouponRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<CouponEntity>>> getActiveCoupons() async {
    try {
      final coupons = await dataSource.getActiveCoupons();
      return Right(coupons);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch coupons: ${e.toString()}'));
    }
  }
}
