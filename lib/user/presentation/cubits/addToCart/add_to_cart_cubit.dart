import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:ship_link/user/domain/repositories/cart_repository.dart';

part 'add_to_cart_state.dart';

class AddToCartCubit extends Cubit<AddToCartState> {
  AddToCartCubit(this.cartServeices) : super(AddToCartInitial());
  final CartRepository cartServeices;

  int _pendingQuantity = 1;
  int get pendingQuantity => _pendingQuantity;
  final ValueNotifier<int> quantityNotifier = ValueNotifier<int>(1);

  void incrementQuantity() {
    _pendingQuantity++;
    quantityNotifier.value = _pendingQuantity;
  }

  void decrementQuantity() {
    _pendingQuantity = _pendingQuantity > 1 ? _pendingQuantity - 1 : 1;
    quantityNotifier.value = _pendingQuantity;
  }

  @override
  Future<void> close() {
    quantityNotifier.dispose();
    return super.close();
  }

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
