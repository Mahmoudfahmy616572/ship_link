import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/services/cartServeices/cart_serveices.dart';

part 'add_to_cart_state.dart';

class AddToCartCubit extends Cubit<AddToCartState> {
  AddToCartCubit(this.cartServeices) : super(AddToCartInitial());
  final CartServeices cartServeices;

  Future<void> addToCart({int? id, int quantity = 1}) async {
    if (!isClosed) emit(AddToCartLoading());
    var result = await cartServeices.addToCart(id: id ?? 0, quantity: quantity);
    result.fold(
      (failure) {
        if (!isClosed) emit(AddToCartFailure(failure.errMessage));
      },
      (success) {
        if (!isClosed) emit(AddToCartSuccess(success));
      },
    );
  }
}
