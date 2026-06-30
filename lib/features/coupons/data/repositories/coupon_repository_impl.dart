import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/core/network/api_exception.dart';
import 'package:tressy/core/network/network_info.dart';
import 'package:tressy/core/network/repository_network_guard.dart';
import 'package:tressy/features/coupons/data/datasources/coupon_remote_datasource.dart';
import 'package:tressy/features/coupons/domain/entities/coupon_entity.dart';
import 'package:tressy/features/coupons/domain/repositories/coupon_repository.dart';

class CouponRepositoryImpl implements CouponRepository {
  final CouponRemoteDataSource dataSource;
  final NetworkInfo networkInfo;

  CouponRepositoryImpl(this.dataSource, this.networkInfo);

  @override
  Future<Either<Failure, List<CouponEntity>>> getActiveCoupons() async {
    final disconnected =
        await leftIfDisconnected<List<CouponEntity>>(networkInfo);
    if (disconnected != null) return disconnected;

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
