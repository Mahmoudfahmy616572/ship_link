import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ship_link/user/data/models/payment/payment.dart';

import 'package:ship_link/user/domain/repositories/cart_repository.dart';

part 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit(this.cartServeices) : super(PaymentInitial());
  final CartRepository cartServeices;
  Future<void> checkout({int? totalPrice, int? orderId, String? redirectUri}) async {
    if (!isClosed) emit(PaymentLoading());
    var result = await cartServeices.checkOut(totalPrice: totalPrice ?? 0, orderId: orderId, redirectUri: redirectUri);
    result.fold(
      (failure) {
        if (!isClosed) emit(PaymentFailure(failure.errMessage));
      },
      (product) {
        if (!isClosed) emit(PaymentSuccess(product));
      },
    );
  }
}
