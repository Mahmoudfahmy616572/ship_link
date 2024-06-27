import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ship_link/data/models/payment/payment.dart';

import '../../data/services/cartServeices/cart_serveices.dart';

part 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit(this.cartServeices) : super(PaymentInitial());
  final CartServeices cartServeices;
  Future<void> checkout({int? totlePrice}) async {
    emit(PaymentLoading());
    var result = await cartServeices.checkOut(totalPrice: totlePrice ?? 0);
    result.fold(
      (failure) {
        print(failure);
        emit(PaymentFailure(failure.errMessage));
      },
      (product) {
        print(product);
        emit(PaymentSuccess(product));
      },
    );
  }
}
