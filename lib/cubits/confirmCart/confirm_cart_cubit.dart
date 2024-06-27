import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ship_link/data/models/confirmCart/confirmCart.dart';
import 'package:ship_link/data/services/cartServeices/cart_serveices.dart';

import '../getFromCart/get_from_cart_cubit.dart';

part 'confirm_cart_state.dart';

class ConfirmCartCubit extends Cubit<ConfirmCartState> {
  ConfirmCartCubit(this.cartServeices) : super(ConfirmCartInitial());
  CartServeices cartServeices;
  Future<void> confirmCart({int? id}) async {
    emit(ConfirmCartLoading());
    var result = await cartServeices.confirmCart(id: id ?? 0);
    result.fold(
      (failure) {
        print(failure.errMessage);
        if (failure.errMessage == "Internal server error , try again later") {
          emit(const ConfirmCartFailure('Order created successfully'));
        } else {
          emit(ConfirmCartFailure(failure.errMessage));
        }
      },
      (success) {
        print(success);
        GetFromCartCubit(cartServeices).getProductFromCart();
        emit(ConfirmCartSuccess(success));
      },
    );
  }
}
