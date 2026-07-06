import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ship_link/user/data/models/confirmCart/confirmCart.dart';
import 'package:ship_link/user/domain/repositories/cart_repository.dart';

part 'confirm_cart_state.dart';

class ConfirmCartCubit extends Cubit<ConfirmCartState> {
  ConfirmCartCubit(this.cartServeices) : super(ConfirmCartInitial());
  CartRepository cartServeices;
  Future<void> confirmCart({
    int? id,
    String? userId,
    String? deliveryAddress,
    double? deliveryLat,
    double? deliveryLng,
    String? addressLabel,
    String? phoneNumber,
    String? deliveryInstructions,
    String paymentMethod = 'cod',
  }) async {
    if (!isClosed) emit(ConfirmCartLoading());
    var result = await cartServeices.confirmCart(
      id: id ?? 0,
      userId: userId ?? '',
      deliveryAddress: deliveryAddress,
      deliveryLat: deliveryLat,
      deliveryLng: deliveryLng,
      addressLabel: addressLabel,
      phoneNumber: phoneNumber,
      deliveryInstructions: deliveryInstructions,
      paymentMethod: paymentMethod,
    );
    result.fold(
      (failure) {
        if (!isClosed) emit(ConfirmCartFailure(failure.errMessage));
      },
      (success) {
        if (!isClosed) emit(ConfirmCartSuccess(success));
      },
    );
  }
}
