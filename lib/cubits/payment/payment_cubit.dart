import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ship_link/data/models/payment/payment.dart';

import '../../data/services/cartServeices/cart_serveices.dart';

part 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit(this.cartServeices) : super(PaymentInitial());
  final CartServeices cartServeices;
  Future<void> checkout({int? totalPrice, int? orderId}) async {
    if (!isClosed) emit(PaymentLoading());
    var result = await cartServeices.checkOut(totalPrice: totalPrice ?? 0, orderId: orderId);
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
