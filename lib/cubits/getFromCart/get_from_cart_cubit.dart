import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ship_link/data/models/getFromCart/get_from_cart.dart';

import '../../data/services/cartServeices/cart_serveices.dart';

part 'get_from_cart_state.dart';

class GetFromCartCubit extends Cubit<GetFromCartState> {
  GetFromCartCubit(this.cartServeices) : super(GetFromCartInitial());
  final CartServeices cartServeices;

  Future<void> getProductFromCart() async {
    if (!isClosed && state is GetFromCartInitial) {
      emit(GetFromCartLoading());
    }
    var result = await cartServeices.getFromCart();
    result.fold(
      (failure) {
        if (!isClosed) emit(GetFromCartFailure(failure.errMessage));
      },
      (product) {
        if (!isClosed) emit(GetFromCartSuccess(product));
      },
    );
  }

  Future<void> deleteFromCart({required int cart_id, required int product_id}) async {
    if (!isClosed) emit(DeleteFromCartLoading());
    var result = await cartServeices.deletefromCart(
        cart_id: cart_id, product_id: product_id);
    result.fold(
      (failure) {
        if (!isClosed) emit(DeleteFromCartFailure(failure.errMessage));
      },
      (_) {
        if (!isClosed) getProductFromCart();
      },
    );
  }
}
