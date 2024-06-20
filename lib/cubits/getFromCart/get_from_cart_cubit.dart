import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ship_link/data/models/getFromCart/get_from_cart.dart';

import '../../data/services/cartServeices/cart_serveices.dart';

part 'get_from_cart_state.dart';

class GetFromCartCubit extends Cubit<GetFromCartState> {
  GetFromCartCubit(this.cartServeices) : super(GetFromCartInitial());
  final CartServeices cartServeices;
  Future<void> getProductFromCart() async {
    emit(GetFromCartLoading());
    var result = await cartServeices.getFromCart();
    result.fold(
      (failure) {
        print(failure);
        emit(GetFromCartFailure(failure.errMessage));
      },
      (product) {
        print(product);
        emit(GetFromCartSuccess(product));
      },
    );
  }
}
