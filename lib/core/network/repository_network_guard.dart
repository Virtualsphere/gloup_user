import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/core/network/network_info.dart';

const String noInternetConnectionMessage = 'No internet connection';

/// Returns [Left(NetworkFailure)] when offline; otherwise `null` to proceed.
Future<Either<Failure, T>?> leftIfDisconnected<T>(
    NetworkInfo networkInfo) async {
  if (await networkInfo.isConnected) return null;
  return const Left(NetworkFailure(noInternetConnectionMessage));
}
