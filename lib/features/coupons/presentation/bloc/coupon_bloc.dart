import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/coupons/domain/usecases/get_active_coupons_usecase.dart';
import 'package:tressy/features/coupons/presentation/bloc/coupon_event.dart';
import 'package:tressy/features/coupons/presentation/bloc/coupon_state.dart';

class CouponBloc extends Bloc<CouponEvent, CouponState> {
  final GetActiveCouponsUseCase getActiveCouponsUseCase;

  CouponBloc({required this.getActiveCouponsUseCase}) : super(const CouponInitial()) {
    on<GetActiveCouponsEvent>(_onGetActiveCoupons);
    on<RefreshCouponsEvent>(_onRefreshCoupons);
  }

  Future<void> _onGetActiveCoupons(GetActiveCouponsEvent event, Emitter<CouponState> emit) async {
    emit(const CouponLoading());

    final result = await getActiveCouponsUseCase();

    result.fold(
      (failure) => emit(CouponFailure(_mapFailureToMessage(failure))),
      (coupons) => emit(CouponLoaded(coupons)),
    );
  }

  Future<void> _onRefreshCoupons(RefreshCouponsEvent event, Emitter<CouponState> emit) async {
    final result = await getActiveCouponsUseCase();

    result.fold(
      (failure) => emit(CouponFailure(_mapFailureToMessage(failure))),
      (coupons) => emit(CouponLoaded(coupons)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return failure.message;
    } else if (failure is ServerFailure) {
      return failure.message;
    } else {
      return 'An unexpected error occurred';
    }
  }
}
