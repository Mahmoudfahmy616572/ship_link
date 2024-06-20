import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ship_link/cubits/getFromCart/get_from_cart_cubit.dart';

import '../../data/services/cartServeices/cart_serveices.dart';

part 'add_to_cart_state.dart';

class AddToCartCubit extends Cubit<AddToCartState> {
  AddToCartCubit(this.cartServeices) : super(AddToCartInitial());
  final CartServeices cartServeices;

  Future<void> addToCart({int? id}) async {
    emit(AddToCartLoading());
    var result = await cartServeices.addToCart(id: id ?? 0);
    result.fold(
      (failure) {
        print(failure);
        emit(AddToCartFailure(failure.errMessage));
      },
      (success) {
        print(success);
        GetFromCartCubit(cartServeices).getProductFromCart();
        emit(AddToCartSuccess(success));
      },
    );
  }
}
